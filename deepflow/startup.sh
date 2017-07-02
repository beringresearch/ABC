# Install R
sh -c 'echo "deb https://cran.r-project.org/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'


gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

add-apt-repository ppa:marutter/rrutter
apt-get update
apt-get upgrade

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install -y gcc-5 g++-5 gfortran-5

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5  

apt-get install -y libxml2-dev libssl0.9.8 libgsl0-dev libudunits2-dev gfortran \
                        libcairo2-dev libcurl4-openssl-dev build-essential \
                        git libatlas-base-dev libopencv-dev fftw3-dev \
                        r-base-core=3.3.1-1trusty0 
apt-cache showpkg r-base


# SQLite
sudo apt-get install -y sqlite3 libsqlite3-dev

# R Packages
sudo R -e "source('https://bioconductor.org/biocLite.R'); biocLite('flowPeaks')"
sudo R -e "install.packages('shiny', repos = 'http://cran.rstudio.com/', dep = TRUE)"
sudo R -e "install.packages('rmarkdown', repos = 'http://cran.rstudio.com/', dep = TRUE)"
sudo R -e "install.packages('devtools', repos='http://cran.rstudio.com/', dep=TRUE)"
sudo R -e "install.packages('flexdashboard', repos='http://cran.rstudio.com/', dep=TRUE)"
sudo R -e "install.packages('DT', repos='http://cran.rstudio.com/', dep=TRUE)"
sudo R -e "install.packages('RSQLite', repos='http://cran.rstudio.com/', dep=TRUE)"
sudo R -e "install.packages('ggplot2', repos='http://cran.rstudio.com/', dep=TRUE)"
sudo R -e "install.packages('data.table', repos='http://cran.rstudio.com/', dep=TRUE)"

sudo R -e "devtools::install_github('elbamos/largeVis')"
sudo R -e "devtools::install_github('beringresearch/ABC/deepflow/pkg')"

mkdir ~/.deepflow/
sudo R -e "deepflow::deepflow_init('deepflow.db', '~/.deepflow/')"
sudo chmod 777 /home/vagrant/.deepflow/deepflow.db

sudo apt-get -y install gdebi-core
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.2.3.368-amd64.deb
sudo gdebi shiny-server-1.2.3.368-amd64.deb
sudo dpkg -i *.deb
rm *.deb
sudo ln -s /vagrant/apps /srv/shiny-server
sudo usermod -a -G vagrant shiny
