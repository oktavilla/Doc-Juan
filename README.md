Doc-Juan
=======

A seductive API for converting HTML documents into specified format. Relies on nginx's [XSendfile](http://wiki.nginx.org/XSendfile) for delivering converted documents.

## Endpoint

### Render

	GET /render
	
#### Parameters
		
`url` - The resource that should be converted to specified format. Required.

`filename` - Filename of the rendered document. Required.

`format` - Output format. Defaults to pdf, currently the only supported format.

`options` - Options for renderer, see below.

`key` - A base64 encoded string of a HMAC digest of ENV['DOC_JUAN_SECRET'] and the parameters sorted by name.

#### Generating a valid key

    require 'openssl'
    sha1 = OpenSSL::Digest::Digest.new('sha1')
    key = OpenSSL::HMAC.hexdigest(sha1, SECRET, 'filename:test-options_title:Test-url:http://example.com')

#### Options

* `title` - PDF title, defaults to the title of the HTML document.
* `print_stylesheet` - If set to `true` the print stylesheet of the resource will be used.
* `width` - Page width in millimeters.
* `height` - Page height in millimeters.
* `size` - a4, letter etc. This will be ignored if width and height is set. [List of sizes](http://stackoverflow.com/questions/6394905/wkhtmltopdf-what-paper-sizes-are-valid).
* `orientation` - `landscape` or `portrait`. Defaults to portrait.
* `lowquality` - Renders the pdf in low quality if set to `true`
	
#### Example
	
	/render?url=http://example.com/document.html&filename=a-document&options[page_size]=A4&key=ABCDEFG
	
#### Returned data

	HTTP/1.1 200 OK
	Date: Wed, 20 Jun 2012 14:11:30 GMT
	Content-Type: application/pdf
	Content-Disposition: attachment; filename="a-document.pdf"
	Cache-Control: public,max-age=2592000
	
	[pdf data]	
	
## Configuration

Doc-Juan is configured by environment variables. The following config variables are available:

* `DOC_JUAN_SECRET` - secret for generating key.
* `DOC_JUAN_DOCUMENT_PATH` - directory to put generated documents.
* `DOC_JUAN_DOCUMENT_URI` - what path the `DOC_JUAN_DOCUMENT_PATH` directory is available via nginx.

Example:
	
	DOC_JUAN_SECRET=thesupersecret
	DOC_JUAN_DOCUMENT_PATH=/app/shared/documents
	DOC_JUAN_DOCUMENT_URI=/documents
	
### Error notifications

Doc-Juan supports error notifications with AirBrake.

To enable AirBrake support, set the environment variable `AIRBRAKE_API_KEY` to your airbrake api key.

## Requirements

* [Ruby 1.9](http://www.ruby-lang.org)
* [nginx](http://nginx.org)
* [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) tested with v0.9.9

## Helper for generating Doc-Juan URLs

[Doc-Juan-Helper](https://github.com/Oktavilla/Doc-Juan-Helper)

## Reference resources

http://blog.jcoglan.com/2012/06/09/why-you-should-never-use-hash-functions-for-message-authentication/

http://code.google.com/p/wkhtmltopdf/

http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltopdf-0.9.9-doc.html

http://wiki.nginx.org/XSendfile

## Future

* PNG / JPEG output support
* Stats for detecting load

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
