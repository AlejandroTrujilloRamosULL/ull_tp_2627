# Programming Techniques course 26-27
- Course duration:  16 September – November 2026
- Place: CCA (Centro de Cálculo del Alumnado)
- Times: Mondays and Wednesdays, 15:00-17:00
- Teacher: Hannu Parviainen (hparviai@ull.edu.es)
- Teaching language: English

This course teaches the basics of modern Fortran programming in astrophysics, version control with Git, and code parallelisation with OpenMP and MPI.

## Scoring
Two options:
- no final exam, but two equally weighted course exercises, or
- a final exam that involves writing a fully working parallelised Fortran program with paper and a pen.

## Literature
- W.S. Brainerd "Guide to Fortran 2008 Programming" (London: Springer, 2015).
- P.S. Pacheco "Parallel Programming with MPI" (San Francisco, CA: Morgan Kaufmann, 1997).
- W. Gropp, E. Lusk, A. Skjellum "Using MPI: Portable Parallel Programming with the Message-Passing Interface" (3rd ed., Cambridge, MA: The MIT Press, 2014).


## Additional literature
- [S. Chacon and B. Straub "Pro Git"](https://git-scm.com/book/en/v2).
- M. Metcalf, J. Reid, M. Cohen "Modern Fortran Explained" (2nd ed., NY: Oxford University Press, 2018). If the last edition of this book is not available, it can be substituted by previous editions from the same authors: "Modern Fortran Explained" (1st ed., 2011), "Fortran 95/2003 Explained" (2004), or "Fortran 90/95 Explained" (1996, 1999).

## Prerequisites

### Installing Fortran
#### Linux users
Use either your package manager or conda (as shown below). Detailed instructions can be found on the [fortran-lang.org](https://fortran-lang.org/learn/os_setup/install_gfortran/) website.

#### Windows users
You can find the instructions for installing GFortran in Windows from the [fortran-lang.org](https://fortran-lang.org/learn/os_setup/install_gfortran/) website.

#### Mac users
The easiest way to install GNU Fortran on Mac is by creating a separate Anaconda environment

    conda create -n fortran -c conda-forge compilers

After which, the conda environment can be activated as

    conda activate fortran 

### Forking and cloning the course repository
1. On GitHub: click "Fork" on the [course repository page](https://github.com/hpparvi/ull_tp_2627)
2. On your computer: clone your fork
``` 
$ git clone git@github.com:your-username/ull_tp_2627.git
$ cd ull_tp_2627
```
3. Verify your remote
```
$ git remote -v
```
---
<p align="center">
&copy;2026 Hannu Parviainen
</p>

