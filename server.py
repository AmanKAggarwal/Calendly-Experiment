from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_url = urlparse(self.path)
        query_params = parse_qs(parsed_url.query)
        link = query_params.get('link', ['Hello World'])[0]

        if link == 'Hello World':
            print("ERRRORRRRRR")

        if self.path == f"/hello?link={link}":
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()

            # HTML page with a button
            html = f'''
            <html>
                <head>
                    <meta name='viewport' content='width=device-width' />
                </head>

                <script>
                    function sendMessage() {{
                        webkit.messageHandlers.myHandler.postMessage("Hello from HTML page!");
                        console.log("message sent", window.parent.origin);
                        fetch('http://127.0.0.1:5000/')
                            .then(response => {{
                                console.log(response);
                            }})
                            .catch(error => {{
                                console.error(error);
                            }});
                    }}
                    function isCalendlyEvent(e) {{
                                return e.data.event &&
                                    e.data.event.indexOf('calendly') === 0;
                            }};
                        
                    window.addEventListener(
                        'message',
                        function(e) {{
                        if (isCalendlyEvent(e)) {{
                            console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                            console.log(e.data);
                        }}
                        }}
                    );
                    
                    function isCalendlyEvent(e) {{
                        console.log('testing' + e.name);
                        return e.data.event &&
                            e.data.event.indexOf('calendly') === 0;
                    }};
                    
                    window.addEventListener('message', function(e) {{
                        console.log('In listener. Event.type: ' + event.type +
                            ' e.data.event: ' + e.data.event + ' event: ' + JSON.stringify(e.data));
                        if (isCalendlyEvent(e)) {{
                            console.log('calendly event!!!!');
                            window.webkit.messageHandlers.myHandler.postMessage('Calendly:' + e.data);
                        }} else {{
                            window.webkit.messageHandlers.myHandler.postMessage('Other:' + e.data);
                        }}
                    }});
                </script>
                <button onclick="sendMessage()">Send Message</button>
                <!-- Calendly inline widget begin -->
                <div class="calendly-inline-widget" data-auto-load="false">
                    <script type="text/javascript" src="https://assets.calendly.com/assets/external/widget.js"></script>
                    <script>
                    Calendly.initInlineWidget({{
                        url: '{link}',
                    }});
                    </script>
                </div>
                <!-- Calendly inline widget end -->
                </html>
            '''

            self.wfile.write(html.encode('utf-8'))
        else:
            self.send_error(404)

if __name__ == '__main__':
    server_address = ('', 8000) # serve on localhost:8000
    httpd = HTTPServer(server_address, RequestHandler)
    print('Server started on http://localhost:8000')
    httpd.serve_forever()

