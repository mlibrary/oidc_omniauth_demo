require 'sinatra'
require 'omniauth'
require 'omniauth_openid_connect'
require 'byebug'

enable :sessions
set :session_secret, ENV['RACK_COOKIE_SECRET'] 

use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: 'https://weblogin.lib.umich.edu',
    discovery: true,
    client_auth_method: 'jwks',
    scope: [:openid, :profile, :email],
    client_options: {
      identifier: ENV['WEBLOGIN_ID'],
      secret: ENV['WEBLOGIN_SECRET'],
      redirect_uri: "http://localhost:4567/auth/openid_connect/callback"
    }
  }
end

get '/auth/openid_connect/callback' do
  auth = request.env['omniauth.auth']
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  session[:info] = info
  redirect '/'
end

get '/auth/failure' do
  "You are not authorized"
end

get '/logout' do
  session.clear

  #This is the Cosign logout CGI on the SHIBBOLETH IDP
  #This lets you put a redirect link after the cosign logout
  redirect "https://lib.umich.edu/"

  #This is the IDP initiated logout endpoint; It will redirect to http://umich.edu 
  #redirect "https://shibboleth.umich.edu/idp/profile/Logout"
end

get '/' do
  "<p>session[:info] #{session[:info].to_h.to_s}</p>" +
    "<p><a href='https://shibboleth.umich.edu/cgi-bin/logout?http://localhost:4567/logout'>Logout</a></p>"
end

before  do
  #pass if the first part of the path is exempted from authentication; 
  #in this case any paths under 'auth' or 'logout' should be exempted
  pass if ['auth', 'logout'].include? request.path_info.split('/')[1] 


  if !session[:authenticated] || Time.now.utc > session[:expires_at]
    redirect '/auth/openid_connect'
  else
    pass
  end

end
