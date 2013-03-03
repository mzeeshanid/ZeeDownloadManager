ZeeDownloadManager
==================

<b>Features:</b>
  <p>1) This download manager uses the ASIHTTPRequest classes to download files.</p> 
  <p>2) Can download files if app is in  background.</p> 
  <p>3) Can download multiple files at a time.</p>
  <p>4) It can resume interrupted downloads.</p>
  <p>5) User can also pause the download.</p></p>
  <p>6)User can retry any download if any error occurred during download.</p>

<p>Screenshot</p>
<img src="Screenshot.png">

<b>USAGE:</b>

You need ASIHTTPRequest classes get it https://github.com/pokeb/asi-http-request and setup your project Copy the ZeeDownloadsViewController.h ,m and xib file in your xcodeproject.

<b>Precautions:</b>

  <p>1) Don't start multiple downloading with the same URL. It will cause inconsistency.</p>

  <p>2) Must retain the "ZeeDownloadsViewController" object. If it is destroyed or release than app will crash because of ASIHTTPRequest delegates.</p>

  <p>3) InterruptedDownloads.txt contains the URL of the request that are started. These URLs are used to resume the interrupted downloads. This file is placed in the document directory. You must take care of this file.</p>
