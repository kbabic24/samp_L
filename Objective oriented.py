class Zgrada():
    def __init__(self,Adresa,Grad,god):
        self.__adresa=Adresa
        self.__grad=Grad
        if god>2020:
            self.__godIzgradnje=2020
        else:
            self.__godIzgradnje=god
    def getAdresa(self):
        return self.__adresa
    def getGrad(self):
        return self.__grad
    def getGodina(self):
        return self.__godIzgradnje

class StambenaZgrada(Zgrada):
    def __init__(self,Adresa,Grad,god,brStan,Vlasnik):
        super().__init__(Adresa,Grad,god)
        if brStan<1:
            self.__brojStanova=1
        else:
            self.__brojStanova=brStan
        if Vlasnik=='':
            self.__vlasnik=Grad
        else:
            self.__vlasnik=Vlasnik
    def getBrojStanova(self):
        return self.__brojStanova
    def getVlasnik(self):
        return self.__vlasnik
    def setVlasnik(self,Vlasnik):
        if Vlasnik=='':
            self.__vlasnik=self.__grad
        else:
            self.__vlasnik=Vlasnik

def test():
    k=StambenaZgrada('Matej','Zagreb',2025,-20,'')
    print(k.getAdresa())
    print(k.getGrad())
    print(k.getGodina())
    print(k.getBrojStanova())
    print(k.getVlasnik())
    k.setVlasnik('Ana')
    print(k.getVlasnik())
test()
