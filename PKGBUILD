# Maintainer: tasty_minerals <tastyminerals@gmail.com>
pkgname=lls
pkgver=1.2
pkgrel=1
pkgdesc="lls is a colorful "ls" alternative with additional file info.
lls provides pleasant colorful highlighting, file information and some easy-to-read permission tags.
In addition lls can draw folder trees with a total files/dirs count."
arch=(any)
url="https://github.com/tastyminerals/lls"
license=('MIT')
depends=('file')
source=('https://raw.githubusercontent.com/tastyminerals/lls/master/lls')
md5sums=('ade8278d0f592d9bb3653a74c13c042d')

package() {
  install -D -m 755 lls ${pkgdir}/usr/bin
}
