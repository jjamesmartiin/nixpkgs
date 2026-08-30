{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  libtool,
  gettext,
  wxGTK32,
  gtk3,
  opencv4,
  libv4l,
  libX11,
  libXext,
  libXtst,
}:

stdenv.mkDerivation {
  pname = "eviacam";
  version = "2.1.4-unstable-2021-03-08";

  src = fetchFromGitHub {
    owner = "cmauri";
    repo = "eviacam";
    rev = "a4032ed9c59def5399a93e74f5ea84513d2f42b1";
    hash = "sha256-T6EIv/qBknqDFpYvXS7lDY7a+2WNcOr5+vHmZYxKVdU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    libtool
    gettext
  ];

  buildInputs = [
    wxGTK32
    gtk3
    opencv4
    libv4l
    libX11
    libXext
    libXtst
  ];

  postPatch = ''
            mkdir -p m4
            touch config.rpath

            # Add macro dirs to configure.ac for aclocal
            sed -i '1a AC_CONFIG_MACRO_DIRS([m4])' configure.ac

            # Fix autotools leading space bug in OPENCVVERSION formatting and comment out gettext macro
            substituteInPlace configure.ac \
              --replace-fail 'printf "% d"' 'printf "%d"' \
              --replace-fail 'AM_GNU_GETTEXT([external])' '# AM_GNU_GETTEXT([external])'

            # Skip po directory in Makefile.am SUBDIRS
            substituteInPlace Makefile.am \
              --replace-fail $'\tpo \\\n' ""

            # Fix wxWidgets 3.2 compatibility: duplicate wxLANGUAGE_SPANISH_MODERN case
            substituteInPlace src/wviacam.cpp \
              --replace-fail "case (wxLANGUAGE_SPANISH_MODERN):" "// case (wxLANGUAGE_SPANISH_MODERN):"

            # Fix wxWidgets 3.2 type cast in wxSingleChoiceDialog
            substituteInPlace src/viacamcontroller.cpp \
              --replace-fail "(char**)NULL," "(void**)NULL,"

            # Disable chmod u+s during install in Nix sandbox
            substituteInPlace src/Makefile.am \
              --replace-fail "chmod u+s \$(DESTDIR)\$(bindir)/eviacamloader" "true"

            # Pass OPENCVVERSION to creavision build
            substituteInPlace creavision/Makefile.am \
              --replace-fail "AM_CPPFLAGS = " "AM_CPPFLAGS = -DOPENCVVERSION=@OPENCVVERSION@ "

            # Ensure OpenCV VideoCapture opens with CAP_V4L2 backend on Linux
            substituteInPlace creavision/crvcamera_cv.cpp \
              --replace-fail "m_pCvCapture->open(m_Id);" "m_pCvCapture->open(m_Id, cv::CAP_V4L2);" \
              --replace-fail "tmpCapture.open(i)" "tmpCapture.open(i, cv::CAP_V4L2)"

            # Fix GTK3 wxWidgets 3.2 wxPaintDC crash on unrealized widget in CCamWindow::OnPaint
            substituteInPlace wxcamwindow/camwindow.cpp \
              --replace-fail "wxPaintDC dc(this);" "if (!IsShown()) return; wxPaintDC dc(this);"

            # Fix wxWidgets 3.2 / GTK3 wxGetDisplay() returning GdkDisplay* instead of X11 Display*
            substituteInPlace src/pointeraction.cpp \
              --replace-fail "new CMouseControl ((void *) wxGetDisplay());" "new CMouseControl ();"

            substituteInPlace wxutil/wxappbar.cpp \
              --replace-fail "new CMouseControl ((void *) wxGetDisplay());" "new CMouseControl ();" \
              --replace-fail "(Display *) wxGetDisplay()" "XOpenDisplay(NULL)" \
              --replace-fail "Window w= GDK_WINDOW_XID (gtk_widget_get_window (gtkWidget));" "if (!gtkWidget || !gtk_widget_get_window(gtkWidget)) return; Window w= GDK_WINDOW_XID (gtk_widget_get_window (gtkWidget)); if (!w) return;"

            substituteInPlace src/cvisualalert.cpp \
              --replace-fail "(Display*) wxGetDisplay()" "XOpenDisplay(NULL)"

            substituteInPlace src/keyboardcode.cpp \
          --replace-fail 'wxGetDisplay()' 'GetEviacamXDisplay()' \
          --replace-fail 'static_cast<Display *>(GetEviacamXDisplay())' 'GetEviacamXDisplay()' \
          --replace-fail '((Display *) GetEviacamXDisplay())' 'GetEviacamXDisplay()' \
          --replace-fail '(Display *) GetEviacamXDisplay()' 'GetEviacamXDisplay()' \
          --replace-fail '#include "simplelog.h"' '#include "simplelog.h"
    static Display* GetEviacamXDisplay() { static Display* dpy = NULL; if (!dpy) dpy = XOpenDisplay(NULL); return dpy; }' \
          --replace-fail 'char keys_return[32];' 'char keys_return[32];
    		XQueryKeymap(GetEviacamXDisplay(), keys_return);
    		for (int keycode = 8; keycode < 256; keycode++) {
    			int byte_idx = keycode / 8;
    			int bit_idx = keycode % 8;
    			if (keys_return[byte_idx] & (1 << bit_idx)) {
    				if (keycode == 37 || keycode == 50 || keycode == 62 || keycode == 64 || keycode == 66 || keycode == 77 || keycode == 105 || keycode == 108 || keycode == 133 || keycode == 134) continue;
    				return FromScanCode(keycode);
    			}
    		}
    		return KeyboardCode(0);
    		if (false)'

        # Enable hotkeys by default so F11 (Enable/Disable) and F10 (Center) work out-of-the-box
        substituteInPlace src/hotkeymanager.cpp \
          --replace-fail "DisableHotKey(*m_HotKeys[i]);" "EnableHotKey(*m_HotKeys[i]);"
  '';

  postInstall = ''
    mkdir -p $out/share/eviacam
    cp -v ${opencv4}/share/opencv*/haarcascades/haarcascade_frontalface_default.xml $out/share/eviacam/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Webcam-based mouse emulator";
    longDescription = ''
      Enable Viacam (eViacam) is a mouse replacement software that moves the
      pointer as you move your head. It works on standard PCs equipped with
      a web camera. No additional hardware is required.
    '';
    homepage = "https://github.com/cmauri/eviacam";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "eviacam";
  };
}
