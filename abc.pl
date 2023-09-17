use strict;
use warnings;
use CGI;
use LWP::UserAgent;
use JSON::XS;

# Azure AD configuration
my $client_id        = '05286b9f-aa10-4b11-8aac-2cf13dd12a24';         # Application (client) ID
my $client_secret    = 'Kbt8Q~zB3BAQMh1233NAavm2_OMRTm5aPRk5XaUt';     # Client Secret
my $redirect_uri     = 'https://webcodex.in/sso-callback';  # Must match the Azure AD configuration
my $authorization_endpoint = 'https://login.microsoftonline.com/64a94e3f-c3b0-4d83-9a81-922b7d7a9be5/oauth2/authorize';
my $token_endpoint   = 'https://login.microsoftonline.com/64a94e3f-c3b0-4d83-9a81-922b7d7a9be5/oauth2/token';
my $graph_api_url    = 'https://graph.microsoft.com/v1.0/me';  # Microsoft Graph API endpoint

# Create a CGI object to handle HTTP requests
my $cgi = CGI->new;
 print $cgi->param('code');
# Handle the SSO callback
if ($cgi->param('code')) {
    my $code = $cgi->param('code');

    # Exchange the authorization code for an access token
    my $token_url = URI->new($token_endpoint);
    $token_url->query_form(
        client_id     => $client_id,
        client_secret => $client_secret,
        code          => $code,
        redirect_uri  => $redirect_uri,
        grant_type    => 'authorization_code',
    );

    # Perform an HTTP POST request to the token endpoint
    my $ua = LWP::UserAgent->new;
    my $response = $ua->post($token_url);

    if ($response->is_success) {
        my $json_response = $response->decoded_content;
        my $token_data = decode_json($json_response);

        my $access_token = $token_data->{'access_token'};

        # Use the $access_token to make a request to Microsoft Graph API to get user information
        my $graph_request = HTTP::Request->new(
            GET => $graph_api_url,
            [ 'Authorization' => "Bearer $access_token" ]
        );
        my $graph_response = $ua->request($graph_request);

        if ($graph_response->is_success) {
            my $user_info = decode_json($graph_response->decoded_content);
            
            # Access user information in $user_info
            print "User Display Name: " . $user_info->{'displayName'} . "\n";
            print "User Email: " . $user_info->{'userPrincipalName'} . "\n";

            # Redirect or render your application's main page
            # ...
        } else {
            # Handle error when fetching user information from Graph API
            print "Error accessing user information from Graph API: " . $graph_response->status_line . "\n";
        }
    } else {
        # Handle authentication failure
        # ...
    }
} else {
    # Redirect the user to Azure AD for authentication
    my $auth_url = URI->new($authorization_endpoint);
    $auth_url->query_form(
        client_id    => $client_id,
        redirect_uri => $redirect_uri,
        response_type => 'code',
        scope        => 'openid profile',  # Adjust scopes as needed
    );

    # Redirect the user to $auth_url
    # ...
      print $cgi->redirect($auth_url);
}
