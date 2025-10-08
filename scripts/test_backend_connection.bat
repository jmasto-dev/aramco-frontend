@echo off
echo ========================================
echo Test de connexion au backend Laravel
echo ========================================
echo.

set BASE_URL=http://127.0.0.1:8000

echo Test 1: Verification de la disponibilite du serveur...
echo URL: %BASE_URL%
curl -s -o nul -w "Status: %%{http_code}\n" %BASE_URL%
echo.

echo Test 2: Test de l'endpoint API health...
echo URL: %BASE_URL%/api/v1/health
curl -s -H "Accept: application/json" -H "User-Agent: Aramco-Frontend-Test/1.0" %BASE_URL%/api/v1/health
echo.
echo.

echo Test 3: Test de l'endpoint API info...
echo URL: %BASE_URL%/api/v1/info
curl -s -H "Accept: application/json" -H "User-Agent: Aramco-Frontend-Test/1.0" %BASE_URL%/api/v1/info
echo.
echo.

echo Test 4: Test de la racine API...
echo URL: %BASE_URL%/api
curl -s -H "Accept: application/json" -H "User-Agent: Aramco-Frontend-Test/1.0" %BASE_URL%/api
echo.
echo.

echo ========================================
echo Tests termines
echo ========================================
echo.
echo Diagnostic:
echo - Si vous voyez du HTML au lieu de JSON, il y a une erreur Laravel
echo - Si vous voyez "404 Not Found", les routes API ne sont pas configurees
echo - Si vous voyez "500 Internal Server Error", il y a une erreur serveur
echo - Verifiez les logs Laravel avec: php artisan log:clear
echo.
