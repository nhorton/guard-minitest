require 'guard/minitest'

module Guard
  class Minitest < Plugin
    class Inspector
      attr_reader :test_folders, :test_file_patterns, :exclude_regexps

      def initialize(test_folders, test_file_patterns, exclude_regexps)
        @test_folders = test_folders.uniq.compact
        @test_file_patterns = test_file_patterns.uniq.compact
        @exclude_regexps = exclude_regexps.uniq.compact
      end

      def clean_all
        clean(test_folders)
      end

      def clean(paths)
        paths.reduce([]) do |memo, path|
          if File.directory?(path)
            memo += _test_files_for_paths(path)
          else
            memo << path if _test_file?(path)
          end
          memo
        end.uniq
      end

      def clear_memoized_test_files
        @all_test_files = nil
      end

      def all_test_files
        @all_test_files ||= _test_files_for_paths
      end

      private

      def _test_files_for_paths(paths = test_folders)
        paths = _join_for_glob(Array(paths))
        files = _join_for_glob(test_file_patterns)

        Dir["#{paths}/**/#{files}"].filter do |file|
          @exclude_regexps.none? { |re| re === file }
        end
      end

      def _test_file?(path)
        _test_files_for_paths.map {|path| File.expand_path(path) }
                             .include?(File.expand_path(path))
      end

      def _join_for_glob(fragments)
        "{#{fragments.join(',')}}"
      end
    end
  end
end
