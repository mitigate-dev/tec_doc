# Ruby client for TecDoc

## Usage

```ruby
gem 'tec_doc', :git => 'git@github.com:mak-it/tec_doc.git'
```

```ruby
require "tec_doc"
I18n.locale = "lv"
TecDoc.client = TecDoc::Client.new(:provider => 330, :country => "lv")
```

## Shell

```bash
$ tec_doc -h
$ tec_doc -p 100 -c lv -l lv
```

## Documentation

```ruby
yardoc && open doc/index.html
```

The official TecDoc Web Service documentation
can be found [here](http://webservicepilot.tecdoc.net/pegasus-2-0).
