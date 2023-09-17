use strict;
use warnings;
use CGI;
use LWP::UserAgent;
use JSON::XS;
# Azure AD configuration
my $client_id     = '05286b9f-aa10-4b11-8aac-2cf13dd12a24';         # Application (client) ID
my $client_secret = 'Kbt8Q~zB3BAQMh1233NAavm2_OMRTm5aPRk5XaUt';     # Client Secret
my $redirect_uri  = 'https://webcodex.in/sso-callback';  # Must match the Azure AD configuration
my $authorization_endpoint  = 'https://login.microsoftonline.com/64a94e3f-c3b0-4d83-9a81-922b7d7a9be5/oauth2/authorize';
my $token_endpoint = 'https://login.microsoftonline.com/64a94e3f-c3b0-4d83-9a81-922b7d7a9be5D/oauth2/token';

# Create a CGI object to handle HTTP requests
my $cgi = CGI->new;

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

        # Use the $access_token to access protected resources
        # ...

        # Redirect or render your application's main page
        # ...
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