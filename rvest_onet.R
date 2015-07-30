install.packages("rvest", dep = T)
library(rvest)



LinkDoArtykulu <- "http://biznes.onet.pl/wiadomosci/medycyna/b-szydlo-proponuje-likwidacje-nfz-w-sluzbie-zdrowia-nie-moze-przede-wszystkim-liczyc/ym44d8"
LinkDoArtykulu.Serwis <- "http://biznes.onet.pl"
ArtykulHTML <- html(LinkDoArtykulu)

# Pobieramy link do strony z komentarzami
KomentarzeHTML <- paste0(LinkDoArtykulu.Serwis, html_attr(html_nodes(ArtykulHTML, ".k_makeComment"), "href"))


KomentarzeHTML.Aktualne <- KomentarzeHTML
Wyniki <- data.frame()
s <- html_session(KomentarzeHTML.Aktualne)
i <- 0 #zabezpieczenie

while((length(html_attr(html_nodes(s, ".k_makeComment"), "href")) > 2 && i < 1000) ||
      (length(html_attr(html_nodes(s, ".k_makeComment"), "href")) == 2 && i == 0)) {
    autor <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_locked") %>% html_text()
    parent.autor <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_parentAuthor") %>% html_text()
    komentarz <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_content") %>% html_text()
    czas <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_nForum_CommentInfo") %>% html_node("span") %>% html_text()
    ocena <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_nodes(".k_nForum_MarkTipUpPercent") %>% html_text()
    ocena.liczba <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_nodes(".k_nForum_MarkTipCount") %>% html_text()
    
    WynikiCzastkowe <- as.data.frame(cbind(autor,komentarz,czas,ocena,ocena.liczba))
    Wyniki <- rbind(Wyniki, WynikiCzastkowe)
    
    KomentarzeHTML.Nastepny <- paste0(LinkDoArtykulu.Serwis, html_attr(html_nodes(s, ".k_makeComment"), "href"))[[2]]
    s <- jump_to(s, KomentarzeHTML.Nastepny)
    i <- i+1
}

autor <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_locked") %>% html_text()
parent.autor <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_parentAuthor") %>% html_text()
komentarz <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_content") %>% html_text()
czas <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_node(".k_nForum_CommentInfo") %>% html_node("span") %>% html_text()
ocena <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_nodes(".k_nForum_MarkTipUpPercent") %>% html_text()
ocena.liczba <- html_nodes(s, ".k_nForum_ReaderContentFrame") %>% html_nodes(".k_nForum_MarkTipCount") %>% html_text()

WynikiCzastkowe <- as.data.frame(cbind(autor,komentarz,czas,ocena,ocena.liczba))
Wyniki <- cbind(rbind(Wyniki, WynikiCzastkowe), dzisaj = Sys.Date())

write.csv(Wyniki, "przyklad1.csv")
