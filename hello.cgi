use strict;
use warnings;
use OAuth::Lite2;
use JSON::WebToken;

# Azure AD configuration
my $tenant_id = 'YOUR_TENANT_ID';
my $client_id = 'YOUR_CLIENT_ID';
my $client_secret = 'YOUR_CLIENT_SECRET';
my $redirect_uri = 'https://yourapp.com/sso-callback';  # Must match the Azure AD configuration

# Initialize OAuth2 client
my $oauth2 = OAuth::Lite2->new(
    client_id     => $client_id,
    client_secret => $client_secret,
    authorization_endpoint => "https://login.microsoftonline.com/$tenant_id/oauth2/authorize",
    token_endpoint         => "https://login.microsoftonline.com/$tenant_id/oauth2/token",
);

# Handle the SSO callback
if (param('code')) {
    my $code = param('code');
    
    # Exchange the authorization code for an access token
    my $token = $oauth2->get_access_token($code, $redirect_uri);
    
    if ($token && $token->token_type eq 'Bearer') {
        my $jwt = JSON::WebToken->new();
        
        # Decode the ID token (contains user information)
        my $id_token = $jwt->decode($token->id_token);
        
        # Access user information from $id_token
        my $user_email = $id_token->{'upn'} || $id_token->{'preferred_username'};
        
        # Authenticate the user in your application
        # ...
        
        # Redirect or render your application's main page
        # ...
    } else {
        # Handle authentication failure
        # ...
    }
} else {
    # Redirect the user to Azure AD for authentication
    my $auth_url = $oauth2->authorize(
        scope         => 'openid profile',
        redirect_uri  => $redirect_uri,
    );
    
    # Redirect the user to $auth_url
    # ...
}
