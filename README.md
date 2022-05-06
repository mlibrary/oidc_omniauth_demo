# oidc_omniauth_demo

This is a demo of how to do authentication with OpenID Connect with omniauth.
It has been tested with the Library OpenID Connect proxy to University of
Michigan weblogin (weblogin.lib.umich.edu), but it should work with any OpenID
Connect provider.

## To build
1) Clone the repository
2) create a .env file with the following values
```
OIDC_ISSUER=
OIDC_CLIENT_ID=
OIDC_CLIENT_SECRET=
```

For authentication in the Library, get these from A&E.

3) build the image
```
docker-compose build
docker-compose run web bundle install
```

4) start the site
```
docker-compose up
```

5) Go to http://localhost:4567 

## Where to see the code
The main code is in `oidc_demo.rb` 
