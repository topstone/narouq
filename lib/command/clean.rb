# frozen_string_literal: true

#
# Copyright 2013 whiteleaf. All rights reserved.
#

require "fileutils"
require_relative "../downloader"
require_relative "../database"
require_relative "../inventory"

module Command
  class Clean < CommandBase
    def self.oneline_help
      "ゴミファイルを削除します"
    end

    def initialize
      super("[<target> ...] [options]")
      @opt.separator <<-EOS

  ・サブタイトルの変更等により参照されなくなったゴミファイルを削除します。
  ・対象小説を指定しなかった場合は直前に変換した小説について検査します。

  Examples:
    narouq clean          # 直前に変換した小説について検査
    narouq clean 6
    narouq clean 6 -f     # 実際に削除
    narouq clean --all    # 全小説について検査
    narouq clean -af      # 全小説について検査して、実際に削除
  Options:
      EOS

      @opt.on("-f", "--force", "指定した小説のゴミファイルを実際に削除する") {
        @options["force"] = true
      }
      @opt.on("-n", "--dry-run", "指定した小説のゴミファイルを表示する") {
        @options["force"] = false
      }
      @opt.on("-a", "--all", "全小説を検査する") {
        @options["all"] = true
      }
    end

    def execute(argv)
      super
      if @options["all"]
        clean_all_directories(@options["force"])
        return
      end
      if argv.empty?
        latest_id = Inventory.load("latest_convert")["id"]
        if latest_id
          dir = Downloader.get_novel_data_dir_by_target(latest_id)
          if dir
            clean_directory(dir, @options["force"])
          else
            error "#{latest_id} は存在しません"
          end
        end
        return
      end
      tagname_to_ids(argv)
      argv.each do |target|
        dir = Downloader.get_novel_data_dir_by_target(target)
        if dir
          clean_directory(dir, @options["force"])
        else
          error "#{target} は存在しません"
        end
      end
    end

    def clean_all_directories(is_remove)
      Database.instance.each_key do |id|
        next if Narou.novel_frozen?(id)
        dir = Downloader.get_novel_data_dir_by_target(id)
        clean_directory(dir, is_remove)
      end
    end

    def clean_directory(dir, is_remove)
      return unless dir
      return unless File.directory?(dir)
      return unless File.exist?(File.join(dir, Downloader::TOC_FILE_NAME))
      orphans = find_orphans(dir)
      orphans.each do |path|
        puts path
        FileUtils.remove_entry_secure(path) if is_remove
      end
    end

    def find_orphans(dir)
      orphans = []
      toc = Downloader.get_toc_data(dir)
      items = toc["subtitles"].map { |item| "#{item['index']} #{item['file_subtitle']}" }
      Dir.glob(File.join(dir, Downloader::RAW_DATA_DIR_NAME, "*.txt")).each do |path|
        orphans.push(path) unless items.include?(File.basename(path, ".*"))
      end
      Dir.glob(File.join(dir, Downloader::SECTION_SAVE_DIR_NAME, "*.yaml")).each do |path|
        orphans.push(path) unless items.include?(File.basename(path, ".*"))
      end
      orphans
    end
  end
end
