# Xport

[![Build Status](https://travis-ci.org/mak-it/xport.svg?branch=master)](https://travis-ci.org/mak-it/xport)
[![Code Climate](https://codeclimate.com/github/mak-it/xport/badges/gpa.svg)](https://codeclimate.com/github/mak-it/xport)

Tabular data export to Excel, CSV, etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xport'
gem 'axlsx'
```

And then execute:

```bash
$ bundle
```

### Usage

```ruby
class User < ActiveRecord::Base; end
User.create(name: "John")
User.create(name: "Ben")

class UserExport < Xport::Export
  include Xport::Axlsx
  include Xport::CSV

  columns do
    column :id
    column :name, header: "Full name" do |user|
      user.name.upcase
    end
    column :email do |user|
      cell = Xport::Cell.new
      cell.value = "#{user.id}@example.com"
      cell.color = "AAAAAA"
      cell
    end
  end
end

UserExport.new(User.all).to_csv
```

Output:

```csv
id,Full name,email
1,JOHN,1@example.com
2,BEN,2@example.com
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mak-it/xport. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
