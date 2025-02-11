# frozen_string_literal: true

#
# Copyright 2013 whiteleaf. All rights reserved.
#

require_relative "../database"
require_relative "list/novel_decorator"

module Command
  class List < CommandBase
    # 更新してから何秒まで色を変更するか
    ANNOTATION_COLOR_TIME_LIMIT = 6 * 60 * 60

    # MEMO: 0 は昔の小説を凍結したままな場合、novel_type が設定されていないので、
    #       nil.to_i → 0 という互換性維持のため
    NOVEL_TYPE_LABEL = %w(連載 連載 短編)

    FILTERS_TYPE = Hash[*%w(series 連載 ss 短編 frozen 凍結 nonfrozen 非凍結)]

    attr_reader :options

    def self.oneline_help
      "現在管理している小説の一覧を表示します"
    end

    # rubocop:disable Metrics/MethodLength
    def initialize
      super("[<limit>] [options]")
      @opt.separator <<-EOS

  ・現在管理している小説の一覧を表示します
  ・表示されるIDは各コマンドで指定することで小説名等を入力する手間を省けます
  ・個数を与えることで、最大表示数を制限できます(デフォルトは全て表示)
  ・narouq listのデフォルト動作を narouq s default_arg.list= で設定すると便利です
  ・パイプで他の narouq コマンドに繋ぐとID入力の代わりにできます

  Examples:
    narouq list             # IDの小さい順に全て表示
    narouq list 10 -r       # IDの大きい順に10件表示
    narouq list 5 -l        # 最近更新のあった5件表示
    narouq list 10 -rl      # 古い順に10件表示
    narouq list -f ss       # 短編小説だけ表示
    narouq list -f "ss frozen"   # 凍結している短編だけ表示

    # 小説家になろうの小説のみを表示
    narouq list --site --grep 小説家になろう
    narouq l -sg 小説家になろう    # 上記と同じ意味
    # 作者“紫炎”を含む小説を表示
    narouq list --author --grep 紫炎
    narouq l -ag 紫炎              # 上記と同じ意味
    # “紫炎”と“なろう”を含む小説を表示(AND検索)
    narouq l -asg "紫炎 なろう"
    # “なろう”を含まない小説を表示(NOT検索)
    narouq l -sg "-なろう"

    # ハーメルンを含む小説にhamelnタグを付ける
    narouq l -sg ハーメルン | narouq t -a hameln
    # 短編を全て凍結する
    narouq l -f ss | narouq freeze --on

    # リストをそのまま保存したい時(echoオプション)
    narouq l -e > list.txt

  Options:
      EOS
      @opt.on("-l", "--latest", "最近更新のあった順に小説を表示する") {
        @options["latest"] = true
      }
      @opt.on("--gl", "更新日ではなく最新話掲載日を使用する") {
        @options["general-lastup"] = true
      }
      @opt.on("-r", "--reverse", "逆順に表示する") {
        @options["reverse"] = true
      }
      @opt.on("-u", "--url", "小説の掲載ページも表示する") {
        @options["url"] = true
      }
      @opt.on("-k", "--kind", "小説の種別（短編／連載）も表示する") {
        @options["kind"] = true
      }
      @opt.on("-s", "--site", "掲載小説サイト名も表示する") {
        @options["site"] = true
      }
      @opt.on("-a", "--author", "作者名も表示する") {
        @options["author"] = true
      }
      @opt.on("-f", "--filter VAL", String,
              "表示を絞るためのフィルター。スペース区切りで複数可\n" \
              "#{' ' * 25}#{filter_type_help}") { |filter|
        @options["filters"] = filter.downcase.split
      }
      @opt.on("-g", "--grep VAL", String,
              "指定された文字列でリストを検索する") { |search|
        @options["grep"] = search.split
      }
      @opt.on("-t", "--tag [TAGS]", String,
              "タグも表示。引数を指定した場合そのタグを含む小説を表示") { |tags|
        if tags
          @options["tags"] = tags.split
        else
          @options["all-tags"] = true
        end
      }
      @opt.on("-e", "--echo", "パイプやリダイレクトでもそのまま出力する") {
        @options["echo"] = true
      }
    end

    def valid_tags?(novel, tags)
      novel_tags = novel["tags"] or return false
      tags.each do |tag|
        return false unless novel_tags.include?(tag)
      end
      true
    end

    def filter_type_help
      FILTERS_TYPE.map { |filter, info|
        "#{filter}(#{info})"
      }.join(",")
    end

    def test_filter(filters, novel_type, frozen)
      apply_sum = filters.inject(0) do |sum, item|
        apply = case item
                when "series"
                  novel_type == 0 || novel_type == 1
                when "ss"
                  novel_type == 2
                when "frozen"
                  frozen
                when "nonfrozen"
                  !frozen
                else
                  stream_io.error "不明なフィルターです(#{item})"
                  stream_io.puts "filters = #{filter_type_help}"
                  exit Narou::EXIT_ERROR_CODE
                end
        sum + (apply ? 1 : 0)
      end
      apply_sum == filters.count
    end

    def header
      [
        " ID ",
        @options["general-lastup"] ? " 掲載日 " : " 更新日 ",
        @options["kind"] ? "種別" : nil,
        @options["author"] ? "作者名" : nil,
        @options["site"] ? "サイト名" : nil,
        "     タイトル"
      ].compact.join(" | ")
    end

    def view_date_type
      @_view_data_type ||= @options["general-lastup"] ? "general_lastup" : "last_update"
    end

    def now
      @now ||= Time.now
    end

    def output_list(novels, limit)
      took_lines = Hash[decorate_lines(novels).take(limit)]
      output_lines(took_lines)
    end

    def decorate_lines(novels)
      filters = @options["filters"] || []
      selected_lines = {}
      novels.each do |novel|
        novel_decorator = NovelDecorator.new(novel, self)
        novel_type = novel["novel_type"].to_i
        id = novel["id"]
        frozen = Narou.novel_frozen?(id)

        unless filters.empty?
          next unless test_filter(filters, novel_type, frozen)
        end

        if @options["tags"]
          next unless valid_tags?(novel, @options["tags"])
        end
        selected_lines[id] = novel_decorator.decorate_line
      end
      grep(selected_lines)
    end

    def grep(selected_lines)
      return selected_lines unless @options["grep"]
      @options["grep"].each do |search_word|
        selected_lines.keep_if { |_, line|
          if search_word =~ /^-(.+)/
            # NOT検索
            !line.include?($1)
          else
            line.include?(search_word)
          end
        }
      end
      selected_lines
    end

    def output_lines(took_lines)
      if STDOUT.tty?
        stream_io.puts header
        stream_io.puts took_lines.values.join("\n").termcolor
      elsif @options["echo"]
        # pipeにそのまま出力するときはansicolorコードが邪魔なので削除
        stream_io.puts header
        stream_io.puts TermColorLight.strip_tag(took_lines.values.join("\n"))
      else
        # pipeに接続するときはIDを渡す
        stream_io.puts took_lines.keys.join(" ")
      end
    end

    def execute(argv)
      disable_logging
      super
      database_values = Database.instance.get_object.values
      limit =
        if !argv.empty? && argv.first =~ /^\d+$/
          argv.first.to_i
        else
          database_values.size
        end
      if @options["latest"]
        database_values = Database.instance.sort_by(view_date_type)
      end
      database_values.reverse! if @options["reverse"]
      output_list(database_values, limit)
    end
  end
end
