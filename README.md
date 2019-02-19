# subtitles.cr

Convert between various subtitle file-formats. Based on
[papnkukn/subsrt](https://github.com/papnkukn/subsrt). Currently converts
between ASS, SSA, SRT, and JSON formats, more formats planned.

## Installation

### As a library

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  subtitles.cr:
    github: dscottboggs/subtitles.cr

```

2. Run `shards install`

### As a command line interface

Download a release binary for your OS from the [releases](https://github.com/dscottboggs/subtitles.cr/releases) section

##### *OR*

1. Install [Crystal](https://crystal-lang.org/reference/installation/index.html)
2. Clone this repository
3. From a shell within the repository, run `shards install && crystal build --release -o/usr/local/bin/subtitles src/subtitles.cr`


## Usage

### As a library
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
  def call(request : HTTP::Request, response : HTTP::Server::Response)
    # Obviously the above steps need applied here too.
    IO.copy ass, response
  end
end
```

### As a command-line utility

##### With actual filenames specified:
```shell
subtitles /path/to/original.subtitles /path/to/output.format
```
The extension of the output file is important, as that's how the
application determines the filetype to output. The input file's type,
however, is detected based on its content, so it can be named anything.

##### Piping and redirecting:
If you wish, you can pipe the outut of this program into another,
or print it directly to your terminal. For example, the following
command will print the first 25 lines of a `.srt` subtitle file,
in JSON format:

```shell
subtitles /path/to/original.srt --to json - | head -n25
```

the only thing to note of importance here is that in lieu of looking for a
an output format in the output format filename, you must specify the `--to`
argument before the output file, and that `-` is used to represent `stdin`
`stdout` depending on the position

## Contributing

1. Fork it (<https://github.com/dscottboggs/subtitles.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

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

Please note that build specs are only a regression test -- they take a snapshot
of the build process and verify that it remains the same. If you add or change a
snapshot, please also include a subtitle file for a public-domain movie or video
with a PR.

## Contributors

- [D. Scott Boggs](https://github.com/dscottboggs) - creator and maintainer
