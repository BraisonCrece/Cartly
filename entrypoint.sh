#!/bin/bash

# Copiar archivos iniciales de traducción si el volumen está vacío
if [ "$(ls -A /rails/config/locale)" ]; then
  echo "config/locale ya contiene archivos persistentes."
else
  echo "Copiando archivos iniciales a config/locale..."
  cp -r /default_locale/* /rails/config/locale/
fi

# Iniciar la aplicación
exec "$@"
