## Copyright (C) 2014 University of Kaiserslautern
## Microelectronic System Design Research Group
##
## This file is part of the FPGAHS Course
## de.uni-kl.eit.course.fpgahs
##
## Matthias Jung <jungma@eit.uni-kl.de>
## Christian De Schryver <schryver@eit.uni-kl.de>

TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp
SOURCES += median.cpp
SOURCES += EasyBMP/EasyBMP.cpp

QMAKE_CXXFLAGS += -std=c++0x

HEADERS += median.h
HEADERS += image.h
