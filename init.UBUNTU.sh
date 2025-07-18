set -e

# Update sistema
apt update && apt upgrade -y

# Instalar dependencias básicas
apt install -y software-properties-common dirmngr gnupg apt-transport-https ca-certificates curl build-essential

# ----------------------
# Instalar R desde CRAN
# ----------------------

# Agregar llave y repositorio de CRAN para Ubuntu 22.04
curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/cran.gpg
echo "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" > /etc/apt/sources.list.d/cran.list

# Actualizar e instalar R con librerias necesarias para compilar los paquetes
apt update
apt install -y r-base r-base-dev build-essential libcurl4-openssl-dev libssl-dev libxml2-dev
 

# Instalar paquetes necesarios
R -e "options(warn=2); install.packages(c('dplyr', 'betareg', 'jsonlite', 'readr', 'StepBeta', 'logger', 'remotes', 'base64enc', 'stringr', 'utf8'), clean = TRUE)"


/* PRUEBAS
paquetes <- c(
  'dplyr', 'betareg', 'jsonlite', 'readr', 'StepBeta',
  'logger', 'remotes', 'base64enc', 'stringr', 'utf8'
)

fallos <- sapply(paquetes, function(p) {
  resultado <- tryCatch({
    library(p, character.only = TRUE)
    TRUE
  }, error = function(e) {
    message(sprintf(" Error cargando %s: %s", p, e$message))
    FALSE
  })
  return(resultado)
})

cat("\nResumen:\n")
cat(sprintf("%d cargados correctamente\n", sum(fallos)))
cat(sprintf("%d fallaron\n", sum(!fallos)))
*/

# ----------------------
# Instalar Python y pip
# ----------------------

apt install -y python3 python3-pip python3-venv
# Instalar paquetes necesarios
pip3 install numpy pandas  ortools scikit-learn scipy 

/* PRUEBAS

import importlib

packages = ["pandas", "numpy", "ortools", "sklearn", "scipy"]

def check_imports():
    for package in packages:
        try:
            importlib.import_module(package)
            print(f"{package}: OK")
        except ImportError:
            print(f"{package}: NO INSTALADO")

if __name__ == "__main__":
    check_imports()

*/
