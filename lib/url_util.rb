require 'securerandom'
require 'sqlite3'
require 'uri'

class URLUtil
# Initializing db and creating tables if not exists
    def initialize
        @base_url = 'http://127.0.0.1:4567/'
        @database = SQLite3::Database.open "url.db"
        create_tables
    end

# Generates a short link
# params
#   String url (mandatory) - full url
#   String custom (oprional) - custom short link
# Returns String
#   genereated short link
#   short link if already exists and not a custom short link
#   "Custom link already exists" if custom short link exists
    def shorten url, custom = nil
        if !custom.to_s.empty?
            result_set = select("select short_urls from urls where short_urls='#{custom}'")
            row = result_set.next_hash

            if row.nil?
                short_url = @base_url + custom
                insert("insert into urls (original_url, short_urls, created_at) values ('#{url}', '#{custom}', datetime('now'))")
                return short_url
            else
                return "Custom link already exists"
            end
        else
            result_set = select("select short_urls from urls where original_url='#{url}'")
            row = result_set.next_hash

            unless row
                sec_random = SecureRandom.uuid()[0..7]
                short_url = @base_url + sec_random
                insert("insert into urls (original_url, short_urls, created_at) values ('#{url}', '#{sec_random}', datetime('now'))")
                return short_url
            else
                short_urls = row["short_urls"]
                return @base_url + short_urls
            end
        end
    end

# Get the actual url
# params
#   String short_url
# Returns String
#   Full url is exists
#   homepage is not exists
    def get_full_url short_url
        result_set = select("select original_url from urls where short_urls = '#{short_url}'")
        row = result_set.next_hash

        if !row.nil?
            orig_url = row["original_url"]
            uri = URI.parse(orig_url)

            insert("insert into visits (short_urls, visited_at) values ('#{short_url}', datetime('now'))")

            if uri.scheme.nil?
                uri.scheme = "http"
                return "#{uri.scheme}://#{orig_url}"
            else
                return orig_url
            end
        end

        return @base_url
    end

# Stats for the the given short link
# params
#   String - short_url
# Returns Hash
#   stats Hash for the given short link
    def get_stats short_url
        stats = {}
        result_set = select("select original_url, created_at from urls where short_urls = '#{short_url}'")
        row = result_set.next_hash

        if !row.nil?
            stats["short_url"] = short_url
            stats["original_url"] = row["original_url"]
            stats["created_at"] = row["created_at"]

            visits = select("select count(*) from visits where short_urls = '#{short_url}'")

            stats["total_visits"] = visits.next_hash["count(*)"]
        else
            stats["error"] = "#{short_url} - doest not exists"
        end

        stats
    end

# Creates the required database tables
# should be moved into migrations tasks
    def create_tables
        create_urls_table_query = "create table if not exists urls (id integer primary key autoincrement, original_url text, short_urls text, created_at text)"
        create_visits_table_query = "create table if not exists visits (id integer primary key autoincrement, short_urls text, visited_at text)"
        @database.execute(create_urls_table_query)
        @database.execute(create_visits_table_query)
    end

    def insert query
        @database.execute query
    end

    def select query
        select_statement = @database.prepare query
        select_statement.execute
    end
end
