# Guard::Entangle

This is a plugin for the Ruby gem [Guard](https://github.com/guard/guard). Guard-Entangle allows you to include one file inline into another. It uses a syntax of `//= path/to/file` to substitute that file in place of that line.

## Common usage

Often you might have separate JavaScript files that need to be included into one file. Or partials of a file that need to be included into a master file.

## Installation

Add this line to your application's Gemfile:

    gem 'guard-entangle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install guard-entangle

## Usage

As mentioned above, this is only a plugin for [Guard](https://github.com/guard/guard) and does not run on it's own. This plugin will look for `//= path/to/file` in a file and then replace it with the contents of the file stated after `//= `. For example:

```
This is some content in the file
//= src/File1.js

This is someother content in the file.
```
When this is triggered, `//= src/File1.js` will be replaced with the contents of _src/File1.js_.

This functionality is not limited to JavaScript files. However, only JavaScript files can be run through Uglifier.

The rules that trigger this behavior are defined in a _Guardfile_ in your project. For further instructions visit the [Guard website](https://github.com/guard/guard). In the _Guardfile_ you can include the following rules:

### Run all / Run
Guard will trigger the files either on their own or by the _run all_ command (when you press enter in Guard).

When a single file is triggered, it will check if the file is a partial or not.

A partial is a file that is not meant to be complied on its own, but is included within another file. Guard-Entangle determines this by check if the file or folder has **_**
 at the start of its name. For example a file named *_File1.js* will be considered to be a partial. Folders that start with _ will be skipped when runnign the run all command. All files within a partials folder should also start with an _.

If it is a partial, it will trigger the _run all_ command. If its not a partial, it will compile that file only. This is because partials don't get compiled on their own, but its their parent that needs to be compiled.

The _run all_ command will take all the file(s) in the input directory (that are not partials) and compile them into the output directory.

### Compile all files in a directory to the output directory

```
guard :entangle, output: 'output', all_on_start: false, input: 'src', uglifier_options: {} do
    watch(%r{^src/.+\..+$})
end
```
This will watch all files that match the regex _%r{^src/.+\..+$}_ or its subdirectory and then compile them into the output directory (:output). If the _run all_ command is triggered, all the files in the source directory (:input) will get compiled into the output directory (:output). In this instance, the input directory is _src_ and the output directory is _output_.

### Compile only one file

```
guard :entangle, output: 'output', all_on_start: false, input: 'src/File1.js', uglifier_options: {} do
    watch(%r{^src/.+\..+$})
end
```
This will watch all files that match the regex _%r{^src/.+\..+$}_ or its subdirectory and then when a file has been changed, it will compile _src/File1.js_ and write the compiled file into _output/File1.js_. This is because the __:output__ folder is defined as output.

### Specifying the output filename
When compiling one file you may choose to specify the name of the output file. This has 2 different behaviors depending on the input. If the input is a directory, then it will entangle all the files into the output file. If the input is a file, then it will take that file and entangle it into the output file.

```
guard :entangle, output: 'output/output.js', all_on_start: false, input: 'src', uglifier_options: {} do
    watch(%r{^src/.+\..+$})
end
```
This will watch all files that match the regex _%r{^src/.+\..+$}_ or its subdirectory and then when a file has been changed, it will compile all the files in _src_ and write the compiled file into _output/output.js_. This is because the __:output__ is defined as that file.

```
guard :entangle, output: 'output/output.js', all_on_start: false, input: 'src/File.js', uglifier_options: {} do
    watch(%r{^src/.+\..+$})
end
```
This will watch all files that match the regex _%r{^src/.+\..+$}_ or its subdirectory and then when a file has been changed, it will compile all the file _src/File.js_ and write the compiled file into _output/output.js_. This is because the __:output__ is defined as that file.

## Options
The options that can be passed are

* :output           = The output file/folder
* :input            = The input file/folder
* :uglify           = If js files should be uglified
* :all_on_start     = If all files should be engtangled when guard has started
* :uglifier_options = {} Pass a Hash of any [uglifier options](https://github.com/lautis/uglifier)
* :force_utf8       = Default is false. If content should be forced to UTF-8 before uglifying
* :copy             = Saves a copy of the non uglified file along with the min file

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
