;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013 Cyril Roelandt <tipecaml@gmail.com>
;;; Copyright © 2015 Amirouche Boubekki <amirouche@hypermove.net>
;;; Copyright © 2016 Al McElrath <hello@yrns.org>
;;; Copyright © 2016, 2017 Nikita <nikita@n0.is>
;;; Copyright © 2015 Dmitry Bogatov <KAction@gnu.org>
;;; Copyright © 2015, 2023 Leo Famulari <leo@famulari.name>
;;; Copyright © 2016 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2017 Alex Griffin <a@ajgrf.com>
;;; Copyright © 2018–2021 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2021 Raghav Gururajan <rg@raghavgururajan.name>
;;; Copyright © 2021 Alexandru-Sergiu Marton <brown121407@posteo.ro>
;;; Copyright © 2021 Nikolay Korotkiy <sikmir@disroot.org>
;;; Copyright © 2022 Jai Vetrivelan <jaivetrivelan@gmail.com>
;;; Copyright © 2022 jgart <jgart@dismail.de>
;;; Copyright © 2022 Antero Mejr <antero@mailbox.org>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (st)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages libbsd)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages ncurses)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages))

(define-public st
  (package
   (name "st")
   (version "0.8.6")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
             (url "https://github.com/BuddhiLW/st")
             (commit "50ac254157e9ea5e7ed40fc87a53d0e244f10d62")))
     (sha256
      (base32 "1c3fwmhpcx3l79wkj1bbv6pnh47jvwzlhr54s3nr00lxcksrkjng"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f                      ; no tests
      #:make-flags
      (list (string-append "CC=" ,(cc-for-target))
            (string-append "TERMINFO="
                           (assoc-ref %outputs "out")
                           "/share/terminfo")
            (string-append "PREFIX=" %output))
      #:phases
      (modify-phases %standard-phases
                     (delete 'configure))))
   (inputs
    `(("libx11" ,libx11)
      ("libxft" ,libxft)
      ("harfbuzz" ,harfbuzz)
      ("fontconfig" ,fontconfig)
      ("freetype" ,freetype)))
   (native-inputs
    (list ncurses ;provides tic program
          pkg-config))
   (home-page "https://st.suckless.org/")
   (synopsis "Simple terminal emulator")
   (description
    "St implements a simple and lightweight terminal emulator.  It
implements 256 colors, most VT10X escape sequences, utf8, X11 copy/paste,
antialiased fonts (using fontconfig), fallback fonts, resizing, and line
drawing.")
   (license license:x11)))
