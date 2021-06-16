# oidc_omniauth_demo

This is a demo of how to do authentication with weblogin using OpenID connect with omniauth.

## To build
1) Clone the repository
2) create a .env file with the following values
```
WEBLOGIN_SECRET='get-this-from-A-&-E'
WEBLOGIN_ID='also-get-this-from-A-&-E'
```
3) build the image
```
docker-compose build
```

4) start the site
```
docker-compose up
```

5) Go to http://localhost:4567 

## Where to see the code
The main code is in `oidc_demo.rb` 
