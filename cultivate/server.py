#!/usr/bin/env python3

import http.server
import subprocess
import urllib.parse
import logging

# Configure logging to file
logging.basicConfig(
    filename='/var/log/cultivate.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Handle GET requests
class RequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        path = self.path
        if path.startswith('/notify'):
            # Parse query parameters
            query = urllib.parse.urlparse(path).query
            params = urllib.parse.parse_qs(query)
            action = params.get('action', [None])[0]
            state = params.get('state', [None])[0]
            hostname = params.get('hostname', [None])[0]

            # Log the received action, state, and hostname
            logging.info(f"Received notification from {hostname} with action {action} and state {state}")

            # Validate action and state parameters
            if not action or not state:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b'Missing action or state\n')
                return

            # Run corresponding script based on action with hostname and state
            try:
                script_path = f'/opt/scripts/{action}.sh'
                subprocess.run([script_path, hostname, state], check=True)
                
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'Action performed successfully\n')
            except subprocess.CalledProcessError as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(f'Action failed: {e}\n'.encode())
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

def run(server_class=http.server.HTTPServer, handler_class=RequestHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting httpd server on port {port}')
    logging.info(f'Starting httpd server on port {port}')
    httpd.serve_forever()

if __name__ == '__main__':
    run()

