# subtitles.cr

Convert between various subtitle file-formats. Based on
[papnkukn/subsrt](https://github.com/papnkukn/subsrt). Currently converts
between ASS, SSA, SRT, and JSON formats, more formats planned.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     subtitles.cr:
       github: your-github-user/subtitles.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "subtitles"

# Read in the subtitle file to an intermediary format
intermediary = Subtitles.parse filepath: "/path/to/sub.srt"

# Convert to the desired format
ass = Subtitles::ASS.new intermediary

# Open the destination file
File.open "/path/to/sub.srt", mode: "w" do |file|
  # Copy in the data
  IO.copy ass, file
end

# Alternatively, serve over HTTP:
module Middleware
  # Obviously the above steps need applied here too.
  def call(request : HTTP::Request, response : HTTP::Server::Response)
    IO.copy ass, response
  end
end
```

## Development

Specs have already been written to verify various formats, so if someone else
gets the chance to implement the remaining formats before I do, follow these
steps:

 1. Write your parser as an implementation of the `Subtitles::Format` interface,
    and store it alongside the other formats in `src/format`.
 2. when you're done, move the symbol for your format from the `PENDING` list to
    `READY` in `spec/spec_helper.cr`.
 3. run `crystal spec`

For example, if you were implementing the `vtt` format, you'd store the
implementation in `src/format/vtt.cr`. In `spec/spec_helper`, `READY` would look
like the below snippet, and when you run `crystal spec` there should be no
failures or errors.

```crystal
READY   = {:SRT, :JSON, :ASS, :SSA, :VTT}
```


## Contributing

1. Fork it (<https://github.com/your-github-user/subtitles.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [D. Scott Boggs](https://github.com/your-github-user) - creator and maintainer
