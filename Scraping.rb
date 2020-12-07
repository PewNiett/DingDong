require 'nokogiri'
require 'open-uri'
require 'json'

class Deputy
    def initialize(firstname, lastname, departement, sex, region)
        @firstname = firstname
        @lastname = lastname
        @departement = departement
        @sex = sex
        @region = region
        @email = @firstname.downcase + "." + @lastname.downcase + "@assemblee-nationale.fr"
     end
    def firstname
        @firstname
    end
    def lastname
        @lastname
    end
    def departement
        @departement
    end
    def sex
        @sex
    end
    def email
        @email
    end
    def region
        @region
    end
end

class NationalAssembly
    def initialize
        doc = Nokogiri::HTML(URI.open("http://www2.assemblee-nationale.fr/deputes/liste/regions/(vue)/tableau"))
        @deputies = Array.new
        tempHash = []
        doc.css('tr').each do |link|
            if (!link.css("td:nth-child(2)").text.to_s.empty?)
                @deputies << Deputy.new(link.css("td:nth-child(2)").text.to_s, link.css("td:nth-child(3)").text.to_s, link.css("td:nth-child(5)").text.to_s, link.css("td:nth-child(1)").text.to_s, link.css("h2").text)
            end
        end
        tempHash = []
        @deputies.each do |deputy|
            tempHash << {"Sexe" => deputy.sex, "firstname" => deputy.firstname, "lastname" => deputy.lastname, "departement" => deputy.departement, "email" => deputy.email}
        end
        File.open("./Deputies.json", "w") do |f|
            f.write(tempHash.to_json)
        end
    end

    def countFemale
        count = 0
        @deputies.each do |deputy|
            if deputy.sex == "Mme"
            count = count + 1
            end
        end
        puts "Nombre de Députés de sexe féminin: " + count.to_s
    end

    def checkDeputiesByName(letters)
        @deputies.each do |deputy|
            if deputy.lastname.downcase.include? letters.downcase
                puts "#{deputy.firstname} #{deputy.lastname} | Sexe: #{deputy.sex} | Departement: #{deputy.departement} | Email: #{deputy.email}"
            end
        end
    end

    def checkDeputiesByDepartment(department)
        count = 0
        @newlist = Array.new
        @deputies.each do |deputy|
            if deputy.departement.downcase.include? department.downcase
                puts "Number: #{count} | #{deputy.firstname} #{deputy.lastname} | Sexe: #{deputy.sex} | Departement: #{deputy.departement} | Email: #{deputy.email} | Region: #{deputy.region}"
                @newlist << deputy
                count += 1
            end
        end
        response = gets.chomp
            if response.to_i > count - 1 || response.to_i < 0
                puts "Mauvais Numéro"
            elsif response.count("^0-9").zero? && !response.empty?
                puts "Vous avez choisi le député numéro #{response.to_s}, #{@newlist[response.to_i].firstname} #{@newlist[response.to_i].lastname}:
Texte à copier:
---------------
"
                return (@newlist[response.to_i])
            else
                puts "Rentrez un Numéro"
            end
    end

end

ASSEMBLY = NationalAssembly.new

def contact
    puts "Entrez votre Prénom"
    prenom = gets.chomp
    puts "Entrez votre Nom"
    nom = gets.chomp
    puts "Entrez votre Département"
    departement = gets.chomp
    puts "Vous êtes #{prenom} #{nom} et votre département est: #{departement}"
    puts "Veulliez choisir un député à contacter:"
    sendEmail(prenom, nom, departement)
end

def sendEmail(prenom, nom, departement)
    mydeputy = ASSEMBLY.checkDeputiesByDepartment(departement)
    type = "Monsieur"
    if mydeputy.sex == "Mme"
        type = "Madame"
    end
    puts "Bonjour #{mydeputy.sex} #{mydeputy.lastname},

Je m’appelle #{prenom} #{nom}, je réside dans #{departement} et je me permet de vous contacter au sujet de votre loi sur l'autorisation des danses fortnites dans tout les lieux publics,
Sachez #{mydeputy.sex} #{mydeputy.lastname} qu'une pétition en ligne a déja récolté plus de 5 800 000 votes afin d'abolir votre loi et que de nombreuses manifestations sont prévues afin
de convaincre l'opinion public ainsi que tous les autres députés de revenir sur votre loi aussi abominable qu'inhumaine.
Je vous conseille donc de faire tout votre possible avant que tout cela ne degenère,
Dans l'attente d'une réponse de votre part,

Je vous adresse #{type}, mes sincères salutations,

Bien cordialement,
#{prenom} #{nom}

---------------

Mail à adresser à #{mydeputy.email}"
end

def handleFunction(nb)
    case nb
    when 1
        ASSEMBLY.countFemale
    when 2
        puts "Entrez un nom de famille"
        lastname = gets.chomp
        ASSEMBLY.checkDeputiesByName(lastname.to_s)
        puts "Voici toutes les personnes ayant '#{lastname}' dans leurs nom de famille"
    when 3
        puts "Non Disponible"
    else
        contact
    end
end

def main
    puts "Choissisez l'exercice:
1: Affiche le nombre de députés de sexe féminin
2: Afficher tous les députés ayant la lettre n dans leur noms
3: Affiche la région ayant le plus de députés.
4: Contacter un député en fonction de votre département."
    exo = gets.chomp
    if exo.to_i > 4 || exo.to_i < 0
        puts "Mauvais Numéro"
    elsif exo.count("^0-9").zero? && !exo.empty?
        handleFunction(exo.to_i)
    else
        puts "Rentrez un Numéro"
    end
end

main