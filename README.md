Doc-Juan
=======

API for converting HTML documents into specified format. 

## Endpoints

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
* `lowquality` - Renders the pdf in low quality when set to `true`
	
#### Example
	
	/render.pdf?url=http://example.com/document.html&filename=a-document&options[page_size]=A4&key=ABCDEFG
	
#### Returned data

	HTTP/1.1 200 OK
	Date: Wed, 20 Jun 2012 14:11:30 GMT
	Content-Type: application/pdf
	Content-Disposition: attachment; filename="a-document.pdf"
	Cache-Control: public,max-age=2592000
	Content-Length: 303288
	
	[pdf data]	

## Reference resources

http://blog.jcoglan.com/2012/06/09/why-you-should-never-use-hash-functions-for-message-authentication/

http://code.google.com/p/wkhtmltopdf/

http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltopdf-0.9.9-doc.html

http://wiki.nginx.org/XSendfile

## Future

* PNG / JPEG output support
* Stats to detect load
* HTTP authentication support
