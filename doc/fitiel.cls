%%% Nepovinná šablona pro projekty IEL %%%
%%% Verze: 2019/01 %%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{fitiel}[2019/10/27 IEL project class]

% základní třída, odvozujeme ze třídy article
\LoadClass[a4paper,11pt]{article}

% nastavení parametrů
\newif\ifczech \let\ifczech\iftrue

\DeclareOption*{}
\ProcessOptions\relax

% odstranění čísla částí (sections) z nadpisů
\renewcommand{\@seccntformat}[1]{}

%% základní balíčky - šablona
\RequirePackage{ifthen}

%% základní balíčky - dokument
\RequirePackage[left=2cm,text={17cm, 24cm},top=3cm]{geometry}
\RequirePackage{graphicx}
\RequirePackage{float}

% utf-8
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}


% klikatelné odkazy (sekce v obsahu)
\RequirePackage[unicode]{hyperref}

%% logo a nastavení správného jazyka pro dokument
% čeština
\ifczech
    \usepackage[czech]{babel}
    \newcommand{\logo}{
        \includegraphics[scale=0.1,keepaspectratio]{fig/logo_cz.png}
    }
\else
\fi