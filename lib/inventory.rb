# -*- coding: utf-8 -*-
#
# Copyright 2013 whiteleaf. All rights reserved.
#

require "yaml"
require_relative "narou"

#
# Narou.rbのシステムが記録するデータ単位
#
# .narou ディレクトリにYAMLファイルとして保存される
#
module Inventory
  def self.load(name, scope)
    @@cache ||= {}
    return @@cache[name] if @@cache[name]
    {}.tap { |h|
      h.extend(Inventory)
      h.init(name, scope)
      @@cache[name] = h
    }
  end

  def init(name, scope)
    dir = case scope
          when :local
            Narou.get_local_setting_dir
          when :global
            Narou.get_global_setting_dir
          else
            raise "Unknown scope"
          end
    @inventory_file_path = File.join(dir, name + ".yaml")
    if File.exists?(@inventory_file_path)
      self.merge!(YAML.load_file(@inventory_file_path))
    end
  end

  def save
    File.write(@inventory_file_path, YAML.dump(self))
  end
end

