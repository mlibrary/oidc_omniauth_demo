require "sinatra"
require "omniauth"
require "omniauth_openid_connect"

enable :sessions
set :session_secret, ENV["RACK_SESSION_SECRET"]

configure :development do
  OmniAuth.config.logger.level = Logger::DEBUG
  set :logging, Logger::DEBUG
end

# use MyMiddleware

use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: ENV["OIDC_ISSUER"],
    discovery: true,
    client_auth_method: "jwks",
    scope: [:openid, :profile],
    client_options: {
      identifier: ENV["OIDC_CLIENT_ID"],
      secret: ENV["OIDC_CLIENT_SECRET"],
      redirect_uri: "http://localhost:4567/auth/openid_connect/callback"
    }
  }
end

get "/auth/openid_connect/callback" do
  auth = request.env["omniauth.auth"]
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  session[:info] = info
  redirect "/"
end

get "/auth/failure" do
  "You are not authorized"
end

get "/logout" do
  session.clear

  # This is the Cosign logout CGI on the SHIBBOLETH IDP
  # This lets you put a redirect link after the cosign logout
  redirect "https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/"

  # This is the IDP initiated logout endpoint; It will redirect to http://umich.edu
  # redirect "https://shibboleth.umich.edu/idp/profile/Logout"
end

get "/" do
  "<p>session[:info] #{session[:info].to_h}</p>" \
    "<p><a href='/logout'>Logout</a></p>"
end

get "/login" do
  <<~HTML
    <h1>Logging You In...<h1>
    <script>
      window.onload = function(){
        document.forms['login_form'].submit();
      }
    </script>
    <form id='login_form' method='post' action='/auth/openid_connect'>
      <input type="hidden" name="authenticity_token" value='#{request.env["rack.session"]["csrf"]}'>
      <noscript>
        <button type="submit">Login</button>
      </noscript>
    </form>
  HTML
end

before do
  # pass if the first part of the path is exempted from authentication;
  # in this case any paths under 'auth', 'logout', and 'login' should be exempted
  pass if ["auth", "logout", "login"].include? request.path_info.split("/")[1]

  if !session[:authenticated] || Time.now.utc > session[:expires_at]
    redirect "/login"
  else
    pass
  end
end
