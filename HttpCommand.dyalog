﻿:Class HttpCommand
⍝ Description::
⍝ HttpCommand is a stand alone utility to issue HTTP commands and return their
⍝ results.  HttpCommand can be used to retrieve the contents of web pages,
⍝ issue calls to web services, and communicate with any service which uses the
⍝ HTTP protocol for communications.
⍝
⍝ N.B. requires Conga - the TCP/IP utility library (see Notes below)
⍝
⍝ Syntax Cheat Sheet::
⍝   result← Get URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝   result← Do Command URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝   result← GetJSON Command URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝
⍝ Overview::
⍝ HttpCommand can be used in two ways:
⍝   1) Create an instance of HttpCommand using ⎕NEW
⍝      This gives you very fine control to specify the command's parameters
⍝      You then use the Run method to execute the request
⍝
⍝        h←⎕NEW HttpCommand                       ⍝ create an instance
⍝        h.(Command URL)←'get' 'www.dyalog.com'   ⍝ set the command parameters
⍝        r←h.Run                                  ⍝ run the request
⍝
⍝   2) Alternatively you can use the "Get" or "Do" methods which make it
⍝      easier to execute some of the more common use cases.
⍝        r←HttpCommand.Get 'www.dyalog.com'
⍝        r←HttpCommand.Do 'get' 'www.dyalog.com'
⍝
⍝ Constructor::
⍝        cmd←⎕NEW HttpCommand [(Command [URL [Params [Headers [Cert [SSLFlags [Priority]]]]]])]
⍝
⍝ Constructor Arguments::
⍝ All of the constructor arguments are also exposed as Public Fields
⍝
⍝   Command  - the case-insensitive HTTP command to issue
⍝              typically one of 'GET' 'POST' 'PUT' 'OPTIONS' 'DELETE' 'HEAD'
⍝
⍝   URL      - the URL to direct the command at
⍝              format is:  [HTTP[S]://][user:pass@]url[:port][/page[?query_string]]
⍝
⍝   Params   - the parameters to pass with the command
⍝              this can be one of
⍝              - a properly URLEncoded simple character vector
⍝              - a namespace containing the named parameters
⍝              - a vector of an even number of character vectors representing name/value pairs
⍝
⍝   Headers  - the HTTP headers for the request
⍝              this can be one of
⍝              - an empty array - this means that only the HttpCommand default headers will be sent
⍝              - a vector of 2-element vectors containing name/value pairs
⍝              - a matrix of [;1] header-name [;2] values
⍝
⍝              these are any additional HTTP headers to send with the request
⍝              or headers whose default values you wish to override
⍝              headers that HttpCommand will set by default are:
⍝               User-Agent     : Dyalog/Conga
⍝               Accept         : */*
⍝               Content-Type   : application/x-www-form-urlencoded
⍝               Content-Length : length of the request body
⍝               Accept-Encoding: gzip, deflate
⍝
⍝   Cert     - if using SSL, this is either:
⍝              - an instance of the X509Cert class (see Conga SSL documentation)
⍝              - or a 2 element vector of character vectors of the [1] client public certificate filename [2] client private key filename
⍝
⍝   SSLFlags - if using SSL, these are the SSL flags as described in the Conga documentation
⍝
⍝   Priority - if using SSL, this is the GNU TLS priority string (generally you won't change this from the default)
⍝
⍝ Notes on Params and query_string:
⍝ When using the 'GET' HTTP command, you may specify parameters using either the query_string or Params
⍝ Hence, the following are equivalent
⍝     HttpCommand.Get 'www.someplace.com?userid=fred'
⍝     HttpComment.Get 'www.someplace.com' ('userid' 'fred')
⍝
⍝ Additional Public Fields::
⍝   LDRC            - if set, this is a reference to the DRC namespace from Conga - otherwise, we look for DRC in the workspace root
⍝   WaitTime        - time (in seconds) to wait for the response (default 30)
⍝   SuppressHeaders - Boolean which, if set to 1, will suppress all HttpCommand-generated headers
⍝                     you may still supply your own headers in the Headers field
⍝   RequestOnly     - Boolean which, if set to 1, will cause HttpCommand to return the formatted request
⍝                     without actually sending it to the server.  This is used in case you need to
⍝                     verify that your request is properly formatted.
⍝   MaxRedirections - the maximum number of redirections to attempt (default 10), ¯1 disables this check
⍝
⍝
⍝ The methods that execute HTTP requests - Do, Get, and Run - return a namespace containing the variables:
⍝   Data          - the response message payload
⍝   HttpVer       - the server HTTP version
⍝   HttpStatus    - the response HTTP status code (200 means OK)
⍝   HttpMessage   - the response HTTP status message
⍝   Headers       - the response HTTP headers
⍝   PeerCert      - the server (peer) certificate if running secure
⍝   Redirections  - a vector (possibly empty) of redirection links
⍝   rc            - the Conga return code (0 means no error, ¯1 means failure to initialize Conga)
⍝   msg           - status/error msg (non-HTTP)  Empty indicates no non-HTTP error
⍝   Command       - the request's HTTP command
⍝   URL           - the request's URL
⍝
⍝ Public Instance Methods::
⍝
⍝   result←Run            - executes the HTTP request
⍝   name AddHeader value  - add a header value to the request headers if it doesn't already exist
⍝   name SetHeader value  - set a request header, adding it if it doesn't exist,
⍝                           overwriting the value if it does exist
⍝
⍝ Public Shared Methods::
⍝
⍝   result←{RequestOnly} Get URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝   - Perform an GET operation on URL
⍝
⍝   result←{RequestOnly} Do  Command URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝   - Perform the HTTP operation specified by Command on URL
⍝
⍝   result←{RequestOnly} GetJSON Command URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝   - Perform the HTTP operation specified by Command on URL
⍝   - Params is converted to JSON and the response data is expected to be in
⍝     JSON format and then converted to APL data
⍝
⍝    Where the arguments are as described in the constructor parameters section.
⍝     Get and Do are shortcut methods to make it easy to execute an HTTP request on the fly.
⍝     GetJSON is a shortcut method to access JSON-based services
⍝
⍝    The optional left argument, RequestOnly, is used to indicate that HttpCommand should
⍝    return the formatted HTTP request string without actually sending the request to the host.
⍝
⍝   (rc msg)←Fix URL [target]
⍝   - Retrieve and fix (in target) an APL script file
⍝   rc is 0 if successful
⍝   Example:
⍝       Fix 'https://raw.githubusercontent.com/Dyalog/MiServer/master/Utils/HtmlUtils.dyalog' #.Utils
⍝
⍝   r←{cpo} Base64Decode vec     - decode a Base64 encoded string
⍝   r←{cpo} Base64Encode vec     - Base64 encode a character vector, or an integer (⎕DR=83) vector
⍝     cpo - optional left argument (for code points only), is useful for encoding raw data like images.
⍝
⍝     Both Base64Decode and Base64Encode assume that the data is UTF-8. (setting cpo defeats this)
⍝     This is useful for exchanging APL code and foreign characters.
⍝
⍝     Examples:
⍝
⍝       Base64Encode '⍺⍴⌊'             ⍝ use default UTF-8
⍝       1 Base64Encode ⎕NREAD ¯1 83 ¯1 ⍝ where a .png file is tied to ¯1
⍝
⍝   r←UrlDecode vec        - decodes a URL-encoded character vector
⍝
⍝   r←{name} UrlEncode arg - URL-encodes string(s)
⍝     arg can be one of
⍝       - a simple character vector (name may be supplied as left argument)
⍝       - a vector of character vectors of name/value pairs
⍝       - a 2-column matrix of name/value pairs
⍝       - a namespace containing named variables
⍝     name - optional left argument name
⍝
⍝     Both UrlDecode and UrlEncode assume that the data is UTF-8
⍝
⍝     Examples:
⍝
⍝       UrlEncode 'Hello World!'
⍝ Hello%20World%21
⍝
⍝       UrlEncode 'phrase' 'Hello World!'
⍝ phrase=Hello%20World%21
⍝
⍝       UrlEncode 'company' 'dyalog' 'language' 'APL'
⍝ company=dyalog&language=APL
⍝
⍝       UrlEncode 2 2⍴'company' 'dyalog' 'language' 'APL'
⍝ company=dyalog&language=APL
⍝
⍝       (ns←⎕NS '').(company language)←'dyalog' 'APL'
⍝       UrlEncode ns
⍝ company=dyalog&language=APL
⍝
⍝ Notes::
⍝ HttpCommand uses Conga for TCP/IP communications and supports both Conga 2 and Conga 3
⍝ Conga 2 uses the DRC namespace
⍝ Conga 3 uses either the Conga namespace or DRC namespace for backwards compatibility
⍝ HttpCommand will search for #.Conga and #.DRC and use them if they exist - or try to ⎕CY them if they're not found
⍝ You can set the CongaRef public field to have HttpCommand use Conga or DRC located other than in the root of the workspace
⍝ Otherwise HttpCommand will attempt to copy Conga or DRC from the conga workspace supplied with Dyalog APL
⍝
⍝ Normally HttpCommand will specify an "Accept-Encoding" request header so that the server can use gzip or deflate compression in the response.
⍝ However, if you use the HEAD HTTP method, this header is not set, so that the content-length header will
⍝   reflect the uncompressed length of the response's body.
⍝   You can add the header manually if you want the compressed message length, e.g.:
⍝   r←HttpCommand.Do 'HEAD' 'someurl' '' (1 2⍴'Accept-Encoding' 'gzip, deflate')
⍝
⍝
⍝ Example Use Cases::
⍝
⍝ Retrieve the contents of a web page
⍝   result←HttpCommand.Get 'www.dyalog.com'
⍝
⍝ Update a record in a web service
⍝   cmd←⎕NEW HttpCommand                        ⍝ create an instance
⍝   cmd.(Command URL)←'PUT' 'www.somewhere.com' ⍝ set a couple of fields
⍝   (cmd.Params←⎕NS '').(id name)←123 'Fred'    ⍝ set the parameters for the "PUT" command
⍝   result←cmd.Run                              ⍝ and run it
⍝
    ⎕ML←⎕IO←1
    :field public Command←'GET'                    ⍝ default HTTP command
    :field public URL←''                           ⍝ requested resource
    :field public Params←''                        ⍝ request parameters
    :field public Headers←0 2⍴⊂''                  ⍝ request headers
    :field public Result                           ⍝ command result namespace
    :field public WaitTime←30                      ⍝ seconds to wait for a response before timing out
    :field public SuppressHeaders←0                ⍝ set to 1 to suppress HttpCommand default request headers
    :field public shared CongaRef←''               ⍝ user-supplied reference to Conga library
    :field public shared LDRC                      ⍝ HttpCommand-set reference to Conga after CongaRef has been resolved
    :field public Cert←⍬                           ⍝ X509 instance if using HTTPS
    :field public SSLFlags←32                      ⍝ SSL/TLS flags - 32 = accept cert without checking it
    :field public Priority←'NORMAL:!CTYPE-OPENPGP' ⍝ default GnuTLS priority string
    :field public PublicCertFile←''                ⍝ if not using an X509 instance, this is the client public certificate file
    :field public PrivateKeyFile←''                ⍝ if not using an X509 instance, this is the client private key file
    :field public RequestOnly←0                    ⍝ set to 1 if you only want to return the generated HTTP request, but not actually send it
    :field public shared MaxRedirections←10        ⍝ set to 0 if you don't want to follow any redirected references, ¯1 for unlimited

    :field public readonly shared ValidFormUrlEncodedChars←'&=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~*+~%'

    ∇ __version←Version
      :Access public shared
      __version←'HttpCommand' '3.8.0' '2021-11-17'
    ∇

    ∇ make
      :Access public
      :Implements constructor
      makeCommon
    ∇

    ∇ make1 args
      :Access public
      :Implements constructor
      ⍝ args - [Command URL Params Headers Cert SSLFlags Priority]
      args←eis args
      Command URL Params Headers Cert SSLFlags Priority←7↑args,(⍴args)↓Command URL Params Headers Cert SSLFlags Priority
      makeCommon
    ∇

    ∇ makeCommon
      Result←⎕NS''
      Result.(Command URL rc msg HttpVer HttpStatus HttpMessage Headers Data PeerCert Redirections)←Command URL ¯1 '' ''⍬''(0 2⍴⊂'')''⍬(0⍴⊂'')
    ∇

    ∇ r←Config
    ⍝ returns current configuration
      :Access public
      r←↑{⍵(⍎⍵)}¨⎕THIS⍎'⎕NL ¯2.2'
    ∇

    ∇ r←Run
      :Access public
      :If 0∊⍴Cert
          r←(Command HttpCmd)URL Params Headers
      :Else
          r←(Cert SSLFlags Priority)(Command HttpCmd)URL Params Headers
      :EndIf
    ∇

    ∇ r←{requestOnly}Get args;hc
    ⍝ Description::
    ⍝ Shortcut method to perform an HTTP GET request
    ⍝ args - [URL Params Headers Cert SSLFlags Priority]
      :Access public shared
      :If 0=⎕NC'requestOnly' ⋄ requestOnly←0 ⋄ :EndIf
      hc←⎕NEW ⎕THIS((⊂'GET'),eis args)
      hc.RequestOnly←requestOnly
      r←hc.Run
    ∇

    ∇ r←{requestOnly}Do args;hc
    ⍝ Description::
    ⍝ Shortcut method to perform an HTTP request
    ⍝ args - [Command URL Params Headers Cert SSLFlags Priority]
      :Access public shared
      :If 0=⎕NC'requestOnly' ⋄ requestOnly←0 ⋄ :EndIf
      hc←⎕NEW ⎕THIS(eis args)
      hc.RequestOnly←requestOnly
      r←hc.Run
    ∇

    ∇ r←{requestOnly}GetJSON args;cmd
    ⍝ Description::
    ⍝ Shortcut method to perform an HTTP request with JSON data as the request and response payloads
    ⍝ args - [Command URL Params Headers Cert SSLFlags Priority]
      :Access public shared
      :If 0=⎕NC'requestOnly' ⋄ requestOnly←0 ⋄ :EndIf
      cmd←⎕NEW ⎕THIS(eis args)
      cmd.RequestOnly←requestOnly
      cmd.('content-type'SetHeader'application/json')
      :If 0∊⍴cmd.Command ⋄ cmd.Command←(1+0∊⍴cmd.Params)⊃'POST' 'GET' ⋄ :EndIf
      :If ~0∊⍴cmd.Params
          :Trap 0
              cmd.Params←1 ⎕JSON cmd.Params
          :Else
              r←cmd.Result
              r.(rc msg)←¯1 'Could not convert parameters to JSON format'
              →Done
          :EndTrap
      :EndIf
      r←cmd.Run
      →requestOnly⍴0
     
      :If r.rc=0
          :If r.HttpStatus=200
              :If ∨/'application/json'⍷lc r.Headers Lookup'content-type'
                  :Trap 0
                      r.Data←⎕JSON r.Data
                  :Else
                      r.(rc msg)←1 'Could not convert response payload to JSON format'
                      →Done
                  :EndTrap
              :Else
                  r.(rc msg)←2 'Response content-type is not application/json'
                  →Done
              :EndIf
          :Else
              r.(rc msg)←3 'HTTP failure'
              →Done
          :EndIf
      :EndIf
      →0
     Done: ⍝ reset ⎕DF if messages have changed
      r.⎕DF 1⌽'][rc: ',(⍕r.rc),' | msg: "',r.msg,'"',(r.rc≥0)/' | HTTP Status: ',(⍕r.HttpStatus),' "',r.HttpMessage,'" | ⍴Data: ',⍕⍴r.Data
    ∇

    ∇ r←{ro}Fix args;z;url;target
    ⍝ retrieve and fix APL code loads the latest version from GitHub
      :Access public shared
      (url target)←2↑(,⊆args),##
      :If 0=⎕NC'ro' ⋄ ro←0 ⋄ :EndIf
      r←z←ro Get{ ⍝ convert url if necessary
          ~∨/'github'⍷⍵:⍵ ⍝ if not github just
          ∨/'raw.githubusercontent.com'⍷⍵:⍵ ⍝ already refers to
          t←'/'(≠⊆⊢)⍵
          i←⍸<\∨/¨'github'∘⍷¨t
          'https://raw.githubusercontent.com',∊'/',¨(2↑i↓t),(⊂'master'),(2+i)↓t
      }url
      →ro⍴0
      :If z.rc≠0
          r←z.(rc msg)
      :ElseIf z.HttpStatus≠200
          r←¯1(⍕z)
      :Else
          :Trap 0
              r←0(⍕target{0::⍺.⎕FX ⍵ ⋄ ⍺.⎕FIX ⍵}{⍵⊆⍨~⍵∊⎕UCS 13 10 65279}z.Data)
          :Else
              r←¯1('Could not ⎕FIX file: ',2↓∊': '∘,¨⎕DMX.(EM Message))
          :EndTrap
      :EndIf
    ∇

    ∇ r←Init r;ref;root;nc;class;dyalog;n;ns;congaCopied
      ⍝↓↓↓ Check is LDRC exists (VALUE ERROR (6) if not), and is LDRC initialized? (NONCE ERROR (16) if not)
      :Hold 'HttpCommandInit'
          :If {6 16 999::1 ⋄ ''≡LDRC:1 ⋄ 0⊣LDRC.Describe'.'}''
              LDRC←''
              :If 9=#.⎕NC'Conga' ⋄ {#.Conga.X509Cert.LDRC←''}⍬ ⋄ :EndIf ⍝ if #.Conga exists, reset X509Cert.LDRC reference
              :If ~0∊⍴CongaRef  ⍝ did the user supply a reference to Conga?
                  LDRC←ResolveCongaRef CongaRef
                  →∆END↓⍨0∊⍴r.msg←(''≡LDRC)/'CongaRef (',(⍕CongaRef),') does not point to a valid instance of Conga'
              :Else
                  :For root :In ##.## #
                      ref nc←root{1↑¨⍵{(×⍵)∘/¨⍺ ⍵}⍺.⎕NC ⍵}ns←'Conga' 'DRC'
                      :If 9=⊃⌊nc ⋄ :Leave ⋄ :EndIf
                  :EndFor
                  :If 9=⊃⌊nc
                      LDRC←ResolveCongaRef root⍎∊ref
                      →∆END↓⍨0∊⍴r.msg←(''≡LDRC)/(⍕root),'.',(∊ref),' does not point to a valid instance of Conga'
                      →∆COPY↓⍨{999::0 ⋄ 1⊣LDRC.Describe'.'}'' ⍝ it's possible that Conga was saved in a semi-initialized state
                  :Else
     ∆COPY:
                      class←⊃⊃⎕CLASS ⎕THIS
                      dyalog←{⍵,'/'↓⍨'/\'∊⍨¯1↑⍵}2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
                      congaCopied←0
                      :For n :In ns
                          :Trap 0
                              n class.⎕CY dyalog,'ws/conga'
                              LDRC←ResolveCongaRef class⍎n
                              →∆END↓⍨0∊⍴r.msg←(''≡LDRC)/n,' was copied from [DYALOG]/ws/conga, but is not valid'
                              congaCopied←1
                              :Leave
                          :EndTrap
                      :EndFor
                      →∆END↓⍨0∊⍴r.msg←(~congaCopied)/'Neither Conga nor DRC were successfully copied from [DYALOG]/ws/conga'
                  :EndIf
              :EndIf
          :EndIf
     ∆END:
      :EndHold
     
    ∇

    ∇ LDRC←ResolveCongaRef CongaRef;z;failed
    ⍝ CongaRef could be a charvec, reference to the Conga or DRC namespaces, or reference to an iConga instance
      :Access public shared  ⍝!!! testing only  - remove :Access after testing
      LDRC←'' ⋄ failed←0
      :Select ⎕NC⊂'CongaRef' ⍝ what is it?
      :Case 9.1 ⍝ namespace?  e.g. CongaRef←DRC or Conga
     Try:
          :Trap 0
              :If ∨/'.Conga'⍷⍕CongaRef ⍝ is it Conga?
                  LDRC←CongaRef.Init'HttpCommand'
              :ElseIf 0≡⊃CongaRef.Init'' ⍝ DRC?
                  LDRC←CongaRef
              :Else
                  →0⊣LDRC←''
              :End
          :Else ⍝ if HttpCommand is reloaded and re-executed in rapid succession, Conga initialization may fail, so we try twice
              :If failed
                  →0⊣LDRC←''
              :Else
                  →Try⊣failed←1
              :EndIf
          :EndTrap
      :Case 9.2 ⍝ instance?  e.g. CongaRef←Conga.Init ''
          LDRC←CongaRef ⍝ an instance is already initialized
      :Case 2.1 ⍝ variable?  e.g. CongaRef←'#.Conga'
          :Trap 0
              LDRC←ResolveCongaRef(⍎∊⍕CongaRef)
          :EndTrap
      :EndSelect
    ∇

    ∇ r←{certs}(cmd HttpCmd)args;url;parms;hdrs;urlparms;p;b;secure;port;host;page;x509;flags;priority;auth;req;err;chunked;chunk;buffer;chunklength;done;data;datalen;header;headerlen;rc;donetime;formContentType;ind;len;obj;evt;dat;clt;z;contentType;redirected;origHost;origPort;noHost;origSecure;msg;timedOut;certfile;keyfile;cert;secureParams;simpleChar;defaultPort
⍝ issue an HTTP command
⍝ certs - optional [X509Cert [SSLValidation [Priority]]]
⍝ args  - [1] URL in format [HTTP[S]://][user:pass@]url[:port][/page[?query_string]]
⍝         {2} parameters is using POST - either a namespace or URL-encoded string
⍝         {3} HTTP headers in form {↑}(('hdr1' 'val1')('hdr2' 'val2'))
⍝ Makes secure connection if left arg provided or URL begins with https:
     
⍝ Result: (conga return code) (HTTP Status) (HTTP headers) (HTTP body) [PeerCert if secure]
     
      :If 900⌶⍬ ⋄ certs←'' ⋄ :EndIf ⍝ default when monadic
     
      args←eis args
      (url parms hdrs)←args,(⍴args)↓''(⎕NS'')''
      hdrs←{0∊t←⍴⍵:0 2⍴⊂'' ⋄ 3=|≡⍵:↑eis∘,¨⍵ ⋄ 2=≢t:⍵ ⋄ ((0.5×t),2)⍴⍵}hdrs
     
      r←Result
      r.(Command URL rc msg HttpVer HttpStatus HttpMessage Headers Data PeerCert Redirections)←cmd url ¯1 '' ''⍬''(0 2⍴⊂'')''⍬(0⍴⊂'')
     
      →∆END↓⍨0∊⍴r.msg←(0∊⍴url)/'No URL specified' ⍝ exit early if no URL
     
      :If ~RequestOnly
          →∆END↓⍨0∊⍴(Init r).msg
      :EndIf
     
      url←,url
      cmd←uc,cmd
     
      redirected←0
     
     GET:
      (url urlparms)←'?'split url
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←(0<⍴,certs)∨(lc(p-2)↑url)≡'https:'
      url←p↓url                                  ⍝ Remove HTTP[s]:// if present
      (host page)←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
      page←{w←⍵ ⋄ ((' '=w)/w)←⊂'%20' ⋄ ∊w}page   ⍝ convert spaces in page name to %20
     
      :If redirected∧noHost←0∊⍴host ⍝ if we're redirected and no host is specified in the location header...
          host←origHost ⍝ ...use original host
          secure←origSecure
          port←origPort
      :EndIf
     
      secureParams←''
      :If secure>RequestOnly
          LDRC.X509Cert.LDRC←LDRC
          :If 0∊⍴certs
              :If ~0∊⍴PublicCertFile
                  certs←⊃LDRC.X509Cert.ReadCertFromFile PublicCertFile
                  certs.KeyOrigin←'DER'PrivateKeyFile
              :EndIf
          :Else
              :If 0 2∊⍨10|⎕DR⊃⊃certs ⍝ file name?
                  :If 2=≡certs
                      (certfile keyfile)←certs
                  :Else
                      (certfile keyfile)←⊃certs
                  :EndIf
                  cert←⊃LDRC.X509Cert.ReadCertFromFile certfile
                  cert.KeyOrigin←'DER'keyfile
                  certs[1]←cert
              :EndIf
          :EndIf
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW LDRC.X509Cert)SSLFlags Priority
          secureParams←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←'Authorization: Basic ',(Base64Encode(¯1+p←host⍳'@')↑host),NL
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      :If ~redirected∧noHost  ⍝ if not redirected and no host was specified in the location header
          :If defaultPort←(≢host)<ind←host⍳':' ⍝ then if there's no port specified in the host
              port←(1+secure)⊃80 443 ⍝ use the default HTTP/HTTPS port
          :Else
              :If 0=port←⊃toNum ind↓host
                  →∆END⊣r.msg←'Invalid host/port - ',host
              :EndIf
              host↑⍨←ind-1
          :EndIf
      :EndIf
     
      :If 0∊⍴host
          →∆END⊣r.msg←'No host specified'
      :EndIf
     
      :If ~(port>0)∧(port≤65535)∧port=⌊port
          →∆END⊣r.msg←'Invalid port - ',⍕port
      :EndIf
     
      hdrs←makeHeaders hdrs
      :If ~SuppressHeaders
          hdrs←'User-Agent'(hdrs addHeader)'Dyalog/Conga'
          hdrs←'Accept'(hdrs addHeader)'*/*'
      :EndIf
     
      :If ~0∊⍴parms                  ⍝ if we have any parameters
          :If (⊆cmd)∊'GET' 'HEAD'    ⍝ if the command is GET or HEAD
              :If {2≠⎕NC'⍵':0 ⋄ 1≥|≡⍵}parms ⍝ simple vector or scalar and not a reference
                  parms←⍕parms       ⍝ deal with possible numeric
              :Else
                  parms←UrlEncode parms
              :EndIf
              urlparms,←urlparms{'&?'[1+0∊⍴⍺],⍵}parms
              parms←''
          :Else    ⍝ not a GET or HEAD command
              ⍝↓↓↓ specify the default content type (if not already specified)
              :If ~SuppressHeaders
                  hdrs←'Content-Type'(hdrs addHeader)formContentType←'application/x-www-form-urlencoded'
              :EndIf
              contentType←hdrs Lookup'Content-Type'
              simpleChar←{1<≢⍴⍵:0 ⋄ (⎕DR ⍵)∊80 82}parms
              :Select ⊃';'(≠⊆⊢)contentType
              :Case formContentType
                  :If simpleChar ⍝ if simple character, parms is assumed to already be
                      :If ~∧/parms∊ValidFormUrlEncodedChars
                          →∆END⊣r.msg←'Params is not a valid URLEncoded string'
                      :EndIf
                  :Else
                      parms←UrlEncode parms
                  :EndIf
              :Case 'application/json'
                  :If ~simpleChar ⍝ if it's a simple charvec, assume it's already JSON format
                      parms←1 ⎕JSON parms
                  :EndIf
              :EndSelect
              :If ~SuppressHeaders
                  hdrs←'Content-Length'(hdrs addHeader)⍴parms
              :EndIf
          :EndIf
      :EndIf
     
     
⍝↓↓↓ If using HEAD method, don't indicate we accept compressed responses
⍝    this way content-length in the response reflects the actual size of the response
⍝    The user can always add the header manually if he wants the compressed size
      :If SuppressHeaders<'HEAD'≢cmd
          hdrs←'Accept-Encoding'(hdrs addHeader)'gzip, deflate'
      :EndIf
     
      req←cmd,' ',(page,urlparms),' HTTP/1.1',NL,(~SuppressHeaders)/'Host: ',host,((~defaultPort)/':',⍕port),NL
      req,←fmtHeaders hdrs
      req,←(~SuppressHeaders)/auth
     
      donetime←⌊⎕AI[3]+1000×WaitTime ⍝ time after which we'll time out
     
      :If RequestOnly
          →0⊣r←req,NL,parms
      :EndIf
     
     Go:
      :If 0=⊃(err clt)←2↑rc←LDRC.Clt''host port'http' 100000,secureParams ⍝ 100,000 is max receive buffer size
     
          {}LDRC.SetProp clt'DecodeBuffers' 15 ⍝ set advanced HTTP parsing
     
          :If 0=⊃rc←LDRC.Send clt(req,NL,parms)
              chunked chunk buffer chunklength←0 '' '' 0
              timedOut done data datalen headerlen header←0 0 ⍬ 0 0 ⍬
     
              :Repeat
                  :If ~done←0≠err←1⊃rc←LDRC.Wait clt 5000            ⍝ Wait up to 5 secs
                      (err obj evt dat)←4↑rc
                      :Select evt
              ⍝ Conga 3.0+ handling
                      :Case 'HTTPHeader'
                          :If 1=≡dat ⍝ HTTP header parsing failed?
                              r.Data←dat
                              r.msg←'Conga failed to parse the response HTTP header'
                              →∆END
                          :Else
                              r.(HttpVersion HttpStatus HttpMessage)←3↑dat
                              header←4⊃dat
                              datalen←⊃(toNum{'∘???∘'≡⍵:'' ⋄ ⍵}header Lookup'Content-Length'),¯1 ⍝ ¯1 if no content length not specified
                              chunked←∨/'chunked'⍷header Lookup'Transfer-Encoding'
                              done←(cmd≡'HEAD')∨chunked<datalen<1
                           ⍝↓↓↓ hack to deal with HTTP/1.0 behavior of no content-length and no transfer-encoding
                           ⍝    see item 7 under https://tools.ietf.org/html/rfc7230#section-3.3.3
                              :If chunked<datalen=¯1
                              :AndIf ∨/'close'⍷header Lookup'Connection' ⍝←←← not sure this is necessary
                                  :If 0=⊃rc←LDRC.Wait clt 100
                                  :AndIf rc[3]∊'BlkLast' 'HTTPBody'
                                      data←4⊃rc
                                  :EndIf
                              :EndIf
                          :EndIf
                      :Case 'HTTPBody'
                          data←dat
                          done←1
                      :Case 'HTTPChunk'
                          :If 1=≡dat ⍝ HTTP chunk parsing failed?
                              r.Data←dat
                              r.msg←'Conga failed to parse the response HTTP chunk'
                              →∆END
                          :Else
                              data,←1⊃dat
                          :EndIf
                      :Case 'HTTPTrailer'
                          :If 2≠≢⍴dat ⍝ HTTP trailer parsing failed?
                              r.Data←dat
                              r.msg←'Conga failed to parse the response HTTP trailer'
                              →∆END
                          :Else
                              header⍪←dat
                              done←1
                          :EndIf
                      :Case 'HTTPFail'
                          r.Data←dat
                          r.msg←'Conga failed to parse the HTTP reponse'
                          →∆END
     
                      :Case 'Timeout'
                          timedOut←done←⎕AI[3]>donetime
     
                      :Case 'Error'
                          →∆END⊣r.msg←'Conga error processing your request: ',,⍕rc
                      :Else  ⍝ This shouldn't happen
                          →∆END⊣r.msg←'*** Unhandled Conga event type - ',evt
                      :EndSelect
     
                  :ElseIf 100=err ⍝ timeout?
                      timedOut←done←⎕AI[3]>donetime
                  :Else           ⍝ some other error (very unlikely)
                      r.msg←'Conga wait error ',,⍕rc
                  :EndIf
              :Until done
     
              :If timedOut
                  →∆END⊣r.(rc msg)←(⊃rc)'Request timed out before server responded'
              :EndIf
     
              :If 0=err
     
                  r.HttpStatus←toNum r.HttpStatus
                  redirected←0
     
                  :Trap 0 ⍝ If any errors occur, abandon conversion
                      :Select z←header Lookup'content-encoding' ⍝ was the response compressed?
                      :Case '∘???∘' ⍝ no content-encoding header, do nothing
                      :Case 'deflate'
                          data←120 ¯100{(2×⍺≡2↑⍵)↓⍺,⍵}83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
                          data←fromutf8 256|¯2(219⌶)data
                      :Case 'gzip'
                          data←fromutf8 256|¯3(219⌶)83 ⎕DR data
                      :Else
                          r.msg←'Unhandled content-encoding: ',z
                      :EndSelect
     
                      :If 0<≢'charset\s*=\s*utf-8'⎕S'&'⍠1⊢header Lookup'content-type'
                          data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
                          data←(65279=⎕UCS⊃data)↓data ⍝ drop off BOM, if any
                      :EndIf
                  :EndTrap
     
                  :If redirected←r.HttpStatus∊301 302 303 307 308 ⍝ redirected? (HTTP status codes 301, 302, 303, 307, 308)
                      :If MaxRedirections<.=¯1,≢r.Redirections
                          r.msg←'Too many redirections (',(⍕MaxRedirections),')'
                          r.rc←¯1
                          →∆END 
                      :Else
                          url←header Lookup'location' ⍝ use the "location" header field for the URL
                          :If ~0∊⍴url
                              r.Redirections,←⊂url
                              (origHost origPort origSecure)←host port secure
                              {}LDRC.Close clt
                              →GET
                          :EndIf
                      :EndIf
                  :EndIf
     
                  :If secure
                  :AndIf 0=⊃z←LDRC.GetProp clt'PeerCert'
                      r.PeerCert←2⊃z
                  :EndIf
              :EndIf
     
              r.(Headers Data)←header data
     
          :Else
              r.msg←'Conga connection failed ',,⍕1↓rc
          :EndIf
      :Else
          r.msg←'Conga client creation failed ',,⍕1↓rc
      :EndIf
     
      r.rc←1⊃rc
     
     ∆END:
      {}{0::⍬ ⋄ LDRC.Close clt}⍬
      r.⎕DF 1⌽'][rc: ',(⍕r.rc),' | msg: "',r.msg,'"',(r.rc=0)/' | HTTP Status: ',(⍕r.HttpStatus),' "',r.HttpMessage,'" | ⍴Data: ',⍕⍴r.Data
     
    ∇

    NL←⎕UCS 13 10
    fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
    utf8←{3=10|⎕DR ⍵: 256|⍵ ⋄ 'UTF-8' ⎕UCS ⍵}
    sint←{⎕io←0 ⋄ 83=⎕DR ⍵:⍵ ⋄ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 ¯128 ¯127 ¯126 ¯125 ¯124 ¯123 ¯122 ¯121 ¯120 ¯119 ¯118 ¯117 ¯116 ¯115 ¯114 ¯113 ¯112 ¯111 ¯110 ¯109 ¯108 ¯107 ¯106 ¯105 ¯104 ¯103 ¯102 ¯101 ¯100 ¯99 ¯98 ¯97 ¯96 ¯95 ¯94 ¯93 ¯92 ¯91 ¯90 ¯89 ¯88 ¯87 ¯86 ¯85 ¯84 ¯83 ¯82 ¯81 ¯80 ¯79 ¯78 ¯77 ¯76 ¯75 ¯74 ¯73 ¯72 ¯71 ¯70 ¯69 ¯68 ¯67 ¯66 ¯65 ¯64 ¯63 ¯62 ¯61 ¯60 ¯59 ¯58 ¯57 ¯56 ¯55 ¯54 ¯53 ¯52 ¯51 ¯50 ¯49 ¯48 ¯47 ¯46 ¯45 ¯44 ¯43 ¯42 ¯41 ¯40 ¯39 ¯38 ¯37 ¯36 ¯35 ¯34 ¯33 ¯32 ¯31 ¯30 ¯29 ¯28 ¯27 ¯26 ¯25 ¯24 ¯23 ¯22 ¯21 ¯20 ¯19 ¯18 ¯17 ¯16 ¯15 ¯14 ¯13 ¯12 ¯11 ¯10 ¯9 ¯8 ¯7 ¯6 ¯5 ¯4 ¯3 ¯2 ¯1[utf8 ⍵]}
    lc←(819⌶) ⍝ lower case conversion
    uc←1∘lc   ⍝ upper case conversion
    dlb←{(+/∧\' '=⍵)↓⍵} ⍝ delete leading blanks
    split←{(p↑⍵)((p←¯1+⍵⍳⍺)↓⍵)} ⍝ split ⍵ on first occurrence of ⍺
    h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳lc ⍵} ⍝ hex to decimal
    d2h←{⎕IO←0 ⋄ '0123456789ABCDEF'[16(⊥⍣¯1)⍵]}
    getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
    toNum←{0∊⍴⍵:⍬ ⋄ 1⊃2⊃⎕VFI ⍕⍵} ⍝ simple char to num
    makeHeaders←{0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵} ⍝ create header structure [;1] name [;2] value
    fmtHeaders←{0∊⍴⍵:'' ⋄ ∊{0∊⍴2⊃⍵:'' ⋄ NL,⍨(firstCaps 1⊃⍵),': ',⍕2⊃⍵}¨↓⍵} ⍝ formatted HTTP headers
    firstCaps←{1↓{(¯1↓0,'-'=⍵) (819⌶)¨ ⍵}'-',⍵} ⍝ capitalize first letters e.g. Content-Encoding
    addHeader←{'∘???∘'≡⍺⍺ Lookup ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺} ⍝ add a header unless it's already defined

    ∇ r←a breakOn w
    ⍝ break left argument at occurences of any element in right argument
      :Access public shared
      r←{a⊆⍨~a∊w}
    ∇

    ∇ r←table Lookup name
    ⍝ lookup a name/value-table value by name, return '∘???∘' if not found
      :Access Public Shared
      r←table{(⍺[;2],⊂'∘???∘')⊃⍨(lc¨⍺[;1])⍳eis lc ⍵}name
    ∇

    ∇ name AddHeader value
    ⍝ add a header unless it's already defined
      :Access public
      Headers←makeHeaders Headers
      Headers←name(Headers addHeader)value
    ∇

    ∇ name SetHeader value;ind
      :Access public
    ⍝ set a header value, overwriting any existing one
      ind←(lc¨Headers[;1])⍳eis lc name
      Headers↑⍨←ind⌈≢Headers
      Headers[ind;]←name value
    ∇

    ∇ r←{a}eis w;f
    ⍝ enclose if simple
      :Access public shared
      f←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵}
      :If 0=⎕NC'a' ⋄ r←f w
      :Else ⋄ r←a f w
      :EndIf
    ∇

      base64←{⎕IO ⎕ML←0 1              ⍝ from dfns workspace - Base64 encoding and decoding as used in MIME.
          chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
          bits←{,⍉(⍺⍴2)⊤⍵}             ⍝ encode each element of ⍵ in ⍺ bits, and catenate them all together
          part←{((⍴⍵)⍴⍺↑1)⊂⍵}          ⍝ partition ⍵ into chunks of length ⍺
          0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵  ⍝ decode a string into octets
          four←{                       ⍝ use 4 characters to encode either
              8=⍴⍵:'=='∇ ⍵,0 0 0 0     ⍝   1,
              16=⍴⍵:'='∇ ⍵,0 0         ⍝   2
              chars[2∘⊥¨6 part ⍵],⍺    ⍝   or 3 octets of input
          }
          cats←⊃∘(,/)∘((⊂'')∘,)        ⍝ catenate zero or more strings
          cats''∘four¨24 part 8 bits ⍵
      }

    ∇ r←{cpo}Base64Encode w
    ⍝ Base64 Encode
    ⍝ Optional cpo (code points only) suppresses UTF-8 translation
    ⍝ if w is numeric (single byte integer), skip any conversion
      :Access public shared
      :If 83=⎕DR w ⋄ r←base64 w
      :ElseIf 0=⎕NC'cpo' ⋄ r←base64'UTF-8'⎕UCS w
      :Else ⋄ r←base64 ⎕UCS w
      :EndIf
    ∇

    ∇ r←{cpo}Base64Decode w
    ⍝ Base64 Decode
    ⍝ Optional cpo (code points only) suppresses UTF-8 translation
      :Access public shared
      :If 0=⎕NC'cpo' ⋄ r←'UTF-8'⎕UCS base64 w
      :Else ⋄ r←⎕UCS base64 w
      :EndIf
    ∇

    ∇ r←DecodeHeader buf;len;d
      ⍝ Decode HTTP Header
      r←0(0 2⍴⊂'')
      :If 0<len←¯1+⊃{((NL,NL)⍷⍵)/⍳⍴⍵}buf
          d←(⍴NL)↓¨{(NL⍷⍵)⊂⍵}NL,len↑buf
          d←↑{((p-1)↑⍵)((p←⍵⍳':')↓⍵)}¨d
          d[;1]←lc¨d[;1]
          d[;2]←dlb¨d[;2]
          r←(len+4)d
      :EndIf
    ∇

    ∇ r←{name}UrlEncode data;⎕IO;format;noname;xlate;hex
      ⍝ data is one of:
      ⍝      - a simple character vector (no name supplied)
      ⍝      - an even number of name/data character vectors
      ⍝       'name' 'fred' 'type' 'student' > 'name=fred&type=student'
      ⍝      - a namespace containing variable(s) to be encoded
      ⍝ cpo is an option switch to send Unicode code points
      ⍝ r    is a character vector of the URLEncoded data
     
      :Access Public Shared
      ⎕IO←0
      format←{
          1=≡⍵:⍺(,⍕⍵)
          ↑⍺∘{⍺(,⍕⍵)}¨⍵
      }
      :If 0=⎕NC'name' ⋄ name←'' ⋄ :EndIf
      noname←0
      :If 9.1=⎕NC⊂'data'
          data←⊃⍪/{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ ⍵{⍵ format ⍺⍎⍵}¨t}data
      :Else
          :Select |≡data
          :CaseList 0 1
              :If 1≥|≡data
                  noname←0∊⍴name
                  data←name(,data)
              :EndIf
          :Case 3 ⍝ nested name/value pairs (('abc' '123')('def' '789'))
              data←⊃,/data
          :EndSelect
      :EndIf
      hex←'%',¨,∘.,⍨⎕D,6↑⎕A
      xlate←{
          i←⍸~⍵∊'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~*'
          0∊⍴i:⍵
          ∊({⊂∊hex['UTF-8'⎕UCS ⍵]}¨⍵[i])@i⊢⍵
      }
      data←xlate¨data
      r←noname↓¯1↓∊data,¨(⍴data)⍴'=&'
    ∇

    ∇ r←UrlDecode r;rgx;rgxu;i;j;z;t;m;⎕IO;lens;fill
      :Access public shared
      ⎕IO←0
      ((r='+')/r)←' '
      rgx←'[0-9a-fA-F]'
      rgxu←'%[uU]',(4×⍴rgx)⍴rgx ⍝ 4 characters
      r←(rgxu ⎕R{{⎕UCS 16⊥⍉16|'0123456789ABCDEF0123456789abcdef'⍳⍵}2↓⍵.Match})r
      :If 0≠⍴i←(r='%')/⍳⍴r
      :AndIf 0≠⍴i←(i≤¯2+⍴r)/i
          z←r[j←i∘.+1 2]
          t←'UTF-8'⎕UCS 16⊥⍉16|'0123456789ABCDEF0123456789abcdef'⍳z
          lens←⊃∘⍴¨'UTF-8'∘⎕UCS¨t  ⍝ UTF-8 is variable length encoding
          fill←i[¯1↓+\0,lens]
          r[fill]←t
          m←(⍴r)⍴1 ⋄ m[(,j),i~fill]←0
          r←m/r
      :EndIf
    ∇

    :Section Documentation Utilities
    ⍝ these are generic utilities used for documentation
    ∇ docn←ExtractDocumentationSections what;⎕IO;box;CR;sections;eis;matches
    ⍝ internal utility function
      ⎕IO←1
      eis←{(,∘⊂∘,⍣(1=≡,⍵))⍵}
      CR←⎕UCS 13
      box←{{⍵{⎕AV[(1,⍵,1)/223 226 222],CR,⎕AV[231],⍺,⎕AV[231],CR,⎕AV[(1,⍵,1)/224 226 221]}⍴⍵}(⍵~CR),' '}
      docn←1↓⎕SRC ⎕THIS
      docn←1↓¨docn/⍨∧\'⍝'=⊃¨docn ⍝ keep all contiguous comments
      docn←docn/⍨'⍝'≠⊃¨docn     ⍝ remove any lines beginning with ⍝⍝
      sections←{∨/'::'⍷⍵}¨docn
      :If ~0∊⍴what
          matches←∨⌿∨/¨(eis(819⌶what))∘.⍷(819⌶)sections/docn
          (sections docn)←((+\sections)∊matches/⍳≢matches)∘/¨sections docn
      :EndIf
      (sections/docn)←box¨sections/docn
      docn←∊docn,¨CR
    ∇
    ∇ r←Documentation
    ⍝ return full documentation
      :Access public shared
      r←ExtractDocumentationSections''
    ∇
    ∇ r←Describe
    ⍝ return description only
      :Access public shared
      r←ExtractDocumentationSections'Description::' 'Syntax Cheat Sheet::'
    ∇
    ∇ r←ShowDoc what
    ⍝ return documentation sections that contain what in their title
    ⍝ what can be a character scalar, vector, or vector of vectors
      :Access public shared
      r←ExtractDocumentationSections what
    ∇
    :EndSection
    ∇ r←Upgrade;z
    ⍝ loads the latest version from GitHub
      :Access public shared
      z←Get'https://raw.githubusercontent.com/Dyalog/library-conga/master/HttpCommand.dyalog'
      :If z.rc≠0
          r←z.(rc msg)
      :ElseIf z.HttpStatus≠200
          r←¯1(⍕z)
      :Else
          {}LDRC.Close'.' ⍝ close Conga
          LDRC←''         ⍝ reset local reference so that Conga gets reloaded
          :Trap 0
              ##.⎕FIX{⍵⊆⍨~⍵∊⎕UCS 13 10 65279}z.Data
              r←0 ''
          :Else
              r←¯1('Could not ⎕FIX new HttpCommand: ',2↓∊': '∘,¨⎕DMX.(EM Message))
          :EndTrap
      :EndIf
    ∇
:EndClass
