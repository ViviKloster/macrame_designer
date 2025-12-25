@echo off
echo ================================
echo SETUP MACRAME DESIGNER
echo ================================
echo.
echo Instalando dependencias Flutter...
flutter pub get

echo Configurando para Web...
flutter config --enable-web

echo ? Setup completado
echo.
echo Para ejecutar:
echo - Backend: cd backend && npm start
echo - Frontend: flutter run -d chrome

pause
