module Import
  module PublicBody
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def import(path, tag, tag_behavior, dry_run,, available_locales = [])

        errors  = []
        error = false

        available_locales = [I18n.default_locale] if available_locales.empty?
        row_index = 1

        ::PublicBody.transaction do

          FasterCSV.parse(text_from_file(path), :headers => true) do |row|
            public_body = find_or_create_public_body(row)

            unless Rails.env.test?
              if row_index % 10 = 0
                STDOUT.write row_index
              end
              STDOUT.write error ? "*" : "."
              STDOUT.flush
            end

            row_index = row_index + 1
          end
        end
      end

      def text_from_file(path)
        converted_text = Iconv.iconv("UTF-8", "WINDOWS-1252", File.read(path)).join
        # Replace double-quotes with two single-quotes so FasterCSV will import
        converted_text.gsub!(/([^,])"([^,\n|\r])/, "\\1''\\2")
        converted_text.gsub!(/([^,])"([^,\n|\r])/, "\\1''\\2")

        # LOCM garbage
        converted_text.gsub("\032", "")
      end

      def find_or_create_public_body(row)
        name = ['name',
        short_name = 'short_name',
        request_mail = 'request_email',
        notes = 'notes',
        publication_scheme = 'publication_scheme',
        home_page = 'home_page',
        string = 'tag_string']

        public_body = PublicBody.find(:first, :conditions => [ "name = ?", name])

        if public_body
          //update tags and other stuff
          public_body.save!
        else

          public_body = PublicBody.create!(
            :name => ... ,

          )
        end
      end


    end

  end
end
