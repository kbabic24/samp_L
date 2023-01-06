import tkinter as tk
from math import pi
#from tkinter import messagebox as tkmsg

p=tk.Tk()

p.minsize(250,100)
p.maxsize(600,600)

p.title('tk')

tekst1=tk.Label(p,text='R=')
tekst1.grid(row=0,column=0)

r=tk.StringVar()
unos1=tk.Entry(p,textvariable=r)
unos1.grid(row=0,column=1)

tekst2=tk.Label(p,text='H=')
tekst2.grid(row=1,column=0)

h=tk.StringVar()
unos2=tk.Entry(p,textvariable=h)
unos2.grid(row=1,column=1)

def pretvorba():
    V=int(r.get())**2*int(h.get())*pi*(1/3)
    labelaOut.config(text=str(V))

tipka=tk.Button(p,text='Izracunaj volumen',command=pretvorba)
tipka.grid(row=2,column=0)

labelaOut=tk.Label(p,text='')
labelaOut.grid(row=3,column=0)

p.mainloop()
