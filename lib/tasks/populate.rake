namespace :populate do
  desc "Run all tasks"
  task run_all: :environment do
    Rake::Task['populate:populate_permissions'].execute
    Rake::Task['populate:populate_roles'].execute
    Rake::Task['populate:populate_genres'].execute
    Rake::Task['populate:populate_thresholds'].execute
    Rake::Task['populate:populate_admin_users'].execute
    Rake::Task['populate:populate_fake_users'].execute
    Rake::Task['populate:populate_artists_producers_venues_events'].execute
    Rake::Task['populate:edit_created_at'].execute
    Rake::Task['populate:likes'].execute
    Rake::Task['populate:update_role_and_trust_levels_permissions'].execute
    Rake::Task['populate:events_to_show'].execute
  end

  desc 'Populate db with permissions'
  task populate_permissions: :environment do
    def setup_actions_controllers_db
      Rails.application.eager_load!
      ApplicationController.subclasses.each do |controller|
        next unless controller.respond_to?(:permission)
        next if controller.name.include?('Devise')
        next if controller.name.include?('Profile')
        next if controller.name.include?('Policies')


        klass = controller.permission
        write_permission(klass.name, :manage)

        controller.authorizable_endpoints.each do |action|
          write_permission(klass.name, action)
        end
      end
    end

    def write_permission(subject_class, action)
      Permission.find_or_create_by!(subject_class:, action:, name: I18n.t(action, scope: [:activerecord, :attributes, :permissions, :actions]))
    end

    setup_actions_controllers_db
  end

  desc "Populate database with roles"
  task populate_roles: :environment do
    # por ahora queda así bien tranqui a modo de ejemplo, después se puede mejorar, la idea acá es crear todos los roles
    # que van si o si como admin y moderador y los CRUD de todos los controllers para las permissions
    # Create some roles
    Role.find_or_create_by!(name: 'admin')
    Role.find_or_create_by!(name: 'moderator')

    # Create some trust levels
    TrustLevel.find_or_create_by!(name: 'level_1', order: 1, days_visited: 0, viewed_events: 0, likes_received: 0, likes_given: 0, comments_count: 0)
    TrustLevel.find_or_create_by!(name: 'level_2', order: 2, days_visited: 5, viewed_events: 10, likes_received: 0, likes_given: 10, comments_count: 3)
    TrustLevel.find_or_create_by!(name: 'level_3', order: 3, days_visited: 20, viewed_events: 20, likes_received: 10, likes_given: 30, comments_count: 15)
  end

  desc "Populate database with genres"
  task populate_genres: :environment do
    Genre.find_or_create_by(name: "Rock")
    Genre.find_or_create_by(name: "Pop")
    Genre.find_or_create_by(name: "Hip Hop")
    Genre.find_or_create_by(name: "Electrónica")
    Genre.find_or_create_by(name: "Reggae")
    Genre.find_or_create_by(name: "Jazz")
    Genre.find_or_create_by(name: "Blues")
    Genre.find_or_create_by(name: "Country")
    Genre.find_or_create_by(name: "R&B")
    Genre.find_or_create_by(name: "Clásica")
    Genre.find_or_create_by(name: "Folk")
    Genre.find_or_create_by(name: "Salsa")
    Genre.find_or_create_by(name: "Metal")
    Genre.find_or_create_by(name: "Punk")
    Genre.find_or_create_by(name: "Indie")
    Genre.find_or_create_by(name: "Reguetón")
  end

  desc "Populate Thresholds"
  task populate_thresholds: :environment do
    PenaltyThreshold.find_or_create_by(penalty_score: 50, days_blocked: 15)
    PenaltyThreshold.find_or_create_by(penalty_score: 100, days_blocked: 25)
    PenaltyThreshold.find_or_create_by(penalty_score: 150, days_blocked: 35)
  end

  desc "Populate Admin Users"
  task populate_admin_users: :environment do
    [{ email: 'tomasespin12@gmail.com', username: 'tomas1646', full_name: 'Tomas Espinosa' },
     { email: 'jokinabarzua@hotmail.com', username: 'jokinAbarzua', full_name: 'Jokin Abarzua' },
     { email: 'ezesalas@gmail.com', username: 'ezeSalas', full_name: 'Eze Salas' },
     { email: 'octalcalde@gmail.com', username: 'octavio', full_name: 'Octa Alcalde' },
     { email: 'lucasmiranda@gmail.com', username: 'lucasMiranda', full_name: 'Lucas Miranda' }].each do |user|
      next if User.find_by(email: user[:email], username: user[:username]).present?

      User.create!({ email: user[:email],
                    username: user[:username],
                    full_name: user[:full_name],
                    password: '123123123',
                    password_confirmation: '123123123',
                    role: Role.find_by(name: 'admin'),
                    confirmed_at: Time.now })
    end
  end

  desc "Populate Fake Users"
  task populate_fake_users: :environment do
    # Crea un arreglo de 20 usuarios ficticios
    Faker::Config.locale = 'es'
    users_to_create = [
      { email: 'correo1@example.com', username: 'JuanPerez', full_name: 'Juan Pérez' },
      { email: 'correo2@example.com', username: 'MariaGomez', full_name: 'María Gómez' },
      { email: 'correo3@example.com', username: 'CarlosRodriguez', full_name: 'Carlos Rodríguez' },
      { email: 'correo4@example.com', username: 'AnaMartinez', full_name: 'Ana Martínez' },
      { email: 'correo5@example.com', username: 'PedroLopez', full_name: 'Pedro López' },
      { email: 'correo6@example.com', username: 'LauraSanchez', full_name: 'Laura Sánchez' },
      { email: 'correo7@example.com', username: 'JavierHernandez', full_name: 'Javier Hernández' },
      { email: 'correo8@example.com', username: 'IsabelGarcia', full_name: 'Isabel García' },
      { email: 'correo9@example.com', username: 'LuisFernandez', full_name: 'Luis Fernández' },
      { email: 'correo10@example.com', username: 'MartaDiaz', full_name: 'Marta Díaz' },
      { email: 'correo11@example.com', username: 'AlejandroTorres', full_name: 'Alejandro Torres' },
      { email: 'correo12@example.com', username: 'CarmenRuiz', full_name: 'Carmen Ruiz' },
      { email: 'correo13@example.com', username: 'DanielGonzalez', full_name: 'Daniel González' },
      { email: 'correo14@example.com', username: 'ElenaLopez', full_name: 'Elena López' },
      { email: 'correo15@example.com', username: 'FranciscoMartinez', full_name: 'Francisco Martínez' },
      { email: 'correo16@example.com', username: 'SilviaSanchez', full_name: 'Silvia Sánchez' },
      { email: 'correo17@example.com', username: 'AntonioGomez', full_name: 'Antonio Gómez' },
      { email: 'correo18@example.com', username: 'RosaRodriguez', full_name: 'Rosa Rodríguez' },
      { email: 'correo19@example.com', username: 'ManuelHernandez', full_name: 'Manuel Hernández' },
      { email: 'correo20@example.com', username: 'PatriciaFernandez', full_name: 'Patricia Fernández' }
]

    users_to_create.each_with_index do |user_data, index|
      next if User.find_by(email: user_data[:email]) || User.find_by(username: user_data[:username])

      index += 1
      # Profile Image
      profile_image = Image.new(image_type: 'profile')
      profile_image_filename = "user#{index}.jpg"
      profile_image_content_type = 'image/jpg'
      profile_path = Rails.root.join('MockData', 'Imagenes', 'Usuarios', profile_image_filename)
      profile_image.file.attach(filename: profile_image_filename, io: File.open(profile_path), content_type: profile_image_content_type)

      # Cover Image
      cover_image = Image.new(image_type: 'cover')
      cover_image_filename = "portada#{index}.jpg"
      cover_image_content_type = 'image/jpg'
      cover_path = Rails.root.join('MockData', 'Imagenes', 'PortadaUsuario', cover_image_filename)
      cover_image.file.attach(filename: cover_image_filename, io: File.open(cover_path), content_type: cover_image_content_type)

      User.create!(
        email: user_data[:email],
        username: user_data[:username],
        full_name: user_data[:full_name],
        password: 'password123',
        password_confirmation: 'password123',
        role_id: TrustLevel.default_trust_level,
        confirmed_at: Time.now,
        profile_image:,
        cover_image:
      )
    end
  end

  desc "Populate Artists, Producers, Venues, Events"
  task populate_artists_producers_venues_events: :environment do
    [
      {
        name: 'Usted Señalemelo',
        nationality: 'Argentina',
        description: 'Usted Señalemelo es una banda argentina de indie rock, formada en Mendoza. El grupo está compuesto por el vocalista y tecladista Juan Saieg, el guitarrista Gabriel "Cocó" Orozco y el baterista Lucca Beguerie Petrich.'
      },
      {
        name: 'Enanitos Verdes',
        nationality: 'Argentina',
        description: 'Los Enanitos Verdes o simplemente Enanitos Verdes, a veces abreviado EV, es una banda argentina de rock en español de Mendoza. Organizado originalmente como un trío con Marciano Cantero, Felipe Staiti y Daniel Piccolo en 1979, luego se les unieron Sergio Embrioni y Tito Dávila.'
      },
      {
        name: 'Soda Stereo',
        nationality: 'Argentina',
        description: 'Soda Stereo es una banda de rock argentina formada en 1982 por Gustavo Cerati, Zeta Bosio y Charly Alberti, ​considerada ampliamente por la crítica especializada como la banda más importante, popular e influyente del rock en español y una leyenda de la música latinoamericana.'
      },
      {
        name: 'Sui Generis',
        nationality: 'Argentina',
        description: 'Sui Generis fue una banda argentina de rock formada principalmente por Charly García (teclados, guitarra acústica, voz y composiciones) y Nito Mestre (flauta, guitarra acústica y voz), considerada como una de las más importantes de los orígenes del rock latinoamericano. Sus canciones (en particular las de sus dos primeros álbumes) se convirtieron virtualmente en himnos cantados por generaciones de argentinos, formando hoy parte del paisaje cultural nacional de ese país. Si bien a lo largo de su carrera la banda contó con otros miembros, fue el dúo García/Mestre el que quedó asociado con el nombre, y al que debieron su enorme fama posterior.'
      },
      {
        name: 'Gustavo Cerati',
        nationality: 'Argentina',
        description: 'Gustavo Cerati fue un músico, cantante y compositor argentino, conocido por ser el líder de la banda Soda Stereo. Su trabajo en la música rock en español lo convirtió en una figura icónica de la música latinoamericana.'
      },
      {
        name: 'Fito Páez',
        nationality: 'Argentina',
        description: 'Fito Páez es un cantante, compositor y músico argentino, una de las figuras más destacadas de la música pop y rock en español. A lo largo de su carrera, ha lanzado numerosos álbumes exitosos y ha ganado reconocimiento tanto a nivel nacional como internacional.'
      },
      {
        name: 'Charly García',
        nationality: 'Argentina',
        description: 'Charly García es un músico, compositor y productor argentino. Ha tenido una influencia significativa en la música rock y pop en español y es conocido por su trabajo con bandas como Sui Generis, Serú Girán y como solista.'
      },
      {
        name: 'Los Fabulosos Cadillacs',
        nationality: 'Argentina',
        description: 'Los Fabulosos Cadillacs es una banda argentina de rock en español y ska, formada en 1985. Han fusionado una variedad de estilos musicales y son conocidos por sus letras políticas y sociales.'
      },
      {
        name: 'Andrés Calamaro',
        nationality: 'Argentina',
        description: 'Andrés Calamaro es un músico y compositor argentino, conocido por su trabajo en Los Rodríguez y su carrera en solitario. Su música abarca géneros como el rock, el pop y el tango.'
      },
      {
        name: 'Gustavo Santaolalla',
        nationality: 'Argentina',
        description: 'Gustavo Santaolalla es un músico, compositor y productor argentino. Ha trabajado en una amplia variedad de estilos musicales y ha sido galardonado con múltiples premios, incluyendo el Óscar a la Mejor Banda Sonora Original.'
      },
      {
        name: 'Los Auténticos Decadentes',
        nationality: 'Argentina',
        description: 'Los Auténticos Decadentes es una banda argentina de rock y pop en español. Han ganado popularidad por su estilo festivo y letras pegajosas.'
      },
      {
        name: 'Cerati y Melero',
        nationality: 'Argentina',
        description: 'Cerati y Melero fue un dúo musical conformado por Gustavo Cerati y Daniel Melero. Juntos crearon música electrónica experimental y lanzaron el álbum "Colores Santos".'
      },
      {
        name: 'Luis Alberto Spinetta',
        nationality: 'Argentina',
        description: 'Luis Alberto Spinetta, también conocido como "El Flaco", fue un influyente músico y compositor argentino. Es considerado una de las figuras más importantes del rock argentino y latinoamericano.'
      },
      {
        name: 'Los Piojos',
        nationality: 'Argentina',
        description: 'Los Piojos fue una banda argentina de rock y blues, conocida por su energética música en vivo y sus letras poéticas.'
      },
      {
        name: 'Mercedes Sosa',
        nationality: 'Argentina',
        description: 'Mercedes Sosa fue una cantante de folklore argentina, reconocida por su poderosa voz y su contribución a la música folklórica y latinoamericana.'
      },
      {
        name: 'Los Pericos',
        nationality: 'Argentina',
        description: 'Los Pericos es una banda argentina de reggae y ska, una de las más influyentes en América Latina en su género.'
      },
      {
        name: 'Taylor Swift',
        nationality: 'Estados Unidos',
        description: "Taylor Swift, nacida el 13 de diciembre de 1989 en Reading, Pensilvania, es una influyente cantante, compositora y actriz estadounidense. Comenzó su carrera en la música country antes de ampliar su estilo hacia el pop, indie folk y rock alternativo. Reconocida por sus letras personales y emotivas, Swift ha ganado numerosos premios, incluyendo múltiples Grammys, y ha establecido récords en la industria musical. Su impacto va más allá de la música, abarcando la moda, la actuación y el activismo en temas como los derechos de autor y la igualdad de género. Con una carrera versátil y exitosa, Taylor Swift se ha convertido en una de las artistas más destacadas de la escena musical global."
      },
      {
        name: 'Divididos',
        nationality: 'Argentina',
        description: 'Divididos es una banda argentina de rock, formada por Ricardo Mollo, Diego Arnedo y Catriel Ciavarella. Han sido pioneros en la mezcla de géneros musicales.'
      },
      {
        name: 'Attaque 77',
        nationality: 'Argentina',
        description: 'Attaque 77 es una banda argentina de punk rock, una de las más icónicas de su género en América Latina.'
      },
      {
        name: 'Illya Kuryaki and the Valderramas',
        nationality: 'Argentina',
        description: 'Illya Kuryaki and the Valderramas, también conocidos como IKV, es un dúo musical argentino de rap y funk.'
      },
      {
        name: 'Roger Waters',
        nationality: 'Reino Unido',
        description: 'Roger Waters es músico y compositor británico, cofundador de la banda Pink Floyd, considerada una de las más influyentes en la historia de la música moderna.'
      }
    ].each do |artist|
      next if Artist.find_by(name: artist[:name]).present?

        filename = "#{artist[:name]}.jpg"
        path = Rails.root.join('MockData', 'Imagenes', 'Artistas', filename)
        content_type = 'image/jpg'
        image = new_image(path, filename, content_type)
  
        Artist.create!({ name: artist[:name],
                         nationality: artist[:nationality],
                         description: artist[:description],
                         image: })
     end

     [
      {
        name: 'Maratone Studios',
        nationality: 'Suecia',
        description: 'Maratone es una compañía de producción musical y fue iniciada por dos productores musicales y compositores, Max Martin y Tom Talomaa. Con sede en Estocolmo, Suecia, se inició en enero de 2001 después del cierre de Cheiron Studios.'
      },
      {
        name: 'Custard Records',
        nationality: 'Estados Unidos de América',
        description: 'Custard Records es un sello discográfico estadounidense, mejor conocido por su éxito con el cantautor inglés James Blunt. El sello está dirigido por la ex miembro de 4 Non Blondes, Linda Perry, y tiene una asociación con la división Atlantic Records de Warner Music Group.'
      },
      {
        name: 'American Recordings',
        nationality: 'Estados Unidos de América',
        description: 'American Recordings es un sello discográfico creado por el productor Rick Rubin en 1988. Su sede se encuentra en Los Ángeles. Entre sus artistas más famosos se encuentran Slayer, The Black Crowes, Danzig, Johnny Cash y System of a Down.'
      },
      {
        name: 'Abbey Road Studios',
        nationality: 'Reino Unido',
        description: 'Abbey Road Studios es un famoso estudio de grabación en Londres, Reino Unido. Ha sido utilizado por muchos artistas icónicos de todo el mundo, incluidos The Beatles. Es conocido por su excelencia en la grabación de música clásica y pop.'
      },
      {
        name: 'Sony Music Entertainment',
        nationality: 'Estados Unidos de América',
        description: 'Sony Music Entertainment es una de las principales compañías discográficas a nivel mundial. Representa a una amplia gama de artistas de diferentes géneros y es conocida por su presencia global en la industria musical.'
      },
      {
        name: 'EMI Music',
        nationality: 'Reino Unido',
        description: 'EMI Music fue una importante compañía discográfica con sede en el Reino Unido. A lo largo de su historia, ha trabajado con artistas destacados como The Beatles, Queen y Pink Floyd.'
      },
      {
        name: 'Interscope Records',
        nationality: 'Estados Unidos de América',
        description: 'Interscope Records es una discográfica estadounidense que ha lanzado música de una variedad de géneros, incluyendo pop, hip-hop y rock. Ha representado a artistas como U2, Lady Gaga y Eminem.'
      },
      {
        name: 'Universal Music Group',
        nationality: 'Estados Unidos de América',
        description: 'Universal Music Group es una de las principales compañías discográficas y de entretenimiento en el mundo. Tiene una amplia presencia internacional y representa a artistas de diversos géneros musicales.',
        links_attributes: [{"title":"Página de la productora","url":"https://www.universalmusic.com/"}]
      },
      {
        name: 'Warner Music Group',
        nationality: 'Estados Unidos de América',
        description: 'Warner Music Group es una de las principales compañías discográficas y de entretenimiento. Tiene un catálogo diverso de artistas que abarcan géneros como el pop, el rock y el hip-hop.'
      },
      {
        name: 'Capitol Records',
        nationality: 'Estados Unidos de América',
        description: 'Capitol Records es una discográfica estadounidense con una rica historia en la música popular. Ha trabajado con artistas icónicos como The Beach Boys y Frank Sinatra.'
      },
      {
        name: 'Motown Records',
        nationality: 'Estados Unidos de América',
        description: 'Motown Records es un sello discográfico legendario que desempeñó un papel fundamental en el desarrollo del soul y el R&B. Ha representado a artistas como Marvin Gaye, Stevie Wonder y The Jackson 5.'
      },
      {
        name: 'Atlantic Records',
        nationality: 'Estados Unidos de América',
        description: 'Atlantic Records es una discográfica estadounidense que ha lanzado música en diversos géneros, incluyendo el rock, el pop y el hip-hop. Ha trabajado con artistas como Led Zeppelin, Aretha Franklin y Bruno Mars.'
      },
      {
        name: 'Def Jam Recordings',
        nationality: 'Estados Unidos de América',
        description: 'Def Jam Recordings es una discográfica estadounidense especializada en hip-hop y música urbana. Ha representado a artistas influyentes como LL Cool J, Jay-Z y Kanye West.'
      },
      {
        name: 'RCA Records',
        nationality: 'Estados Unidos de América',
        description: 'RCA Records es una discográfica estadounidense que ha lanzado música en una variedad de géneros. Ha trabajado con artistas como Elvis Presley, Whitney Houston y Justin Timberlake.'
      },
      {
        name: 'Sub Pop Records',
        nationality: 'Estados Unidos de América',
        description: 'Sub Pop Records es un sello discográfico independiente conocido por su papel en el movimiento grunge de Seattle. Ha representado a bandas como Nirvana, Soundgarden y Pearl Jam.'
      },
      {
        name: 'Island Records',
        nationality: 'Reino Unido',
        description: 'Island Records es una discográfica británica con una historia notable en la música rock y pop. Ha trabajado con artistas como U2, Bob Marley y Amy Winehouse.'
      },
      {
        name: 'Columbia Records',
        nationality: 'Estados Unidos de América',
        description: 'Columbia Records es una discográfica estadounidense con una larga historia en la industria musical. Ha lanzado música de artistas icónicos como Bruce Springsteen, Beyoncé y Adele.'
      },
      {
        name: 'Parlophone Records',
        nationality: 'Reino Unido',
        description: 'Parlophone Records es una discográfica británica con un catálogo que incluye a The Beatles, Coldplay y David Bowie. Ha tenido un impacto significativo en la música británica.'
      },
      {
        name: 'Mute Records',
        nationality: 'Reino Unido',
        description: 'Mute Records es un sello discográfico independiente conocido por su trabajo con artistas en el ámbito de la música electrónica y experimental. Ha representado a Depeche Mode, Moby y Goldfrapp.'
      },
      {
        name: 'XL Recordings',
        nationality: 'Reino Unido',
        description: 'XL Recordings es un sello discográfico británico que ha tenido un papel destacado en la música electrónica y el indie. Ha lanzado música de The Prodigy, Adele y Radiohead.'
      },
      {
        name: 'Domino Recording Company',
        nationality: 'Reino Unido',
        description: 'Domino Recording Company es un sello discográfico independiente con sede en el Reino Unido. Ha representado a bandas como Arctic Monkeys, Franz Ferdinand y Animal Collective.'
      },
      {
        name: 'Merge Records',
        nationality: 'Estados Unidos de América',
        description: 'Merge Records es un sello discográfico independiente con sede en Carolina del Norte. Ha trabajado con bandas indie notables como Arcade Fire, Spoon y Neutral Milk Hotel.'
      },
      {
        name: 'Jagjaguwar',
        nationality: 'Estados Unidos de América',
        description: 'Jagjaguwar es un sello discográfico independiente con sede en Indiana. Ha lanzado música de artistas como Bon Iver, Dinosaur Jr. y Angel Olsen.'
      },
      {
        name: 'Fat Possum Records',
        nationality: 'Estados Unidos de América',
        description: 'Fat Possum Records es un sello discográfico independiente especializado en blues y rock. Ha trabajado con artistas como R.L. Burnside, The Black Keys y Andrew Bird.'
      },
      {
        name: '4AD',
        nationality: 'Reino Unido',
        description: '4AD es un sello discográfico británico que ha lanzado música en el ámbito del indie y el rock alternativo. Ha representado a bandas como The National, Cocteau Twins y Pixies.'
      },
      {
        name: 'Nuclear Blast',
        nationality: 'Alemania',
        description: 'Nuclear Blast es un sello discográfico alemán especializado en música metal. Ha trabajado con bandas de diversos subgéneros del metal, incluyendo Dimmu Borgir, Slayer y Nightwish.'
      },
      {
        name: 'DF Entertainment',
        nationality: 'Argentina',
        description: "DF Entertainment es la empresa líder de entretenimiento en vivo en Argentina. Fundada por Diego Finkelstein, quien cuenta con más de 20 años de trayectoria dentro de la industria, la productora presentó el año pasado shows como Coldplay, Harry Styles, Dua Lipa, Rosalía, Maroon 5,  C. Tangana, Guns N' Roses, Kiss, Metallica, Maneskin, Demi Lovato, entre muchos otros.",
        links_attributes: [{"title":"Página de la productora","url":"https://dfentertainment.com/"}]
      }
      ].each do |producer|
       next if Producer.find_by(name: producer[:name]).present?

       producer = Producer.new({ name: producer[:name],
                                 nationality: producer[:nationality],
                                 description: producer[:description]})

      filename = "#{producer[:name]}.jpg"
      path = Rails.root.join('MockData', 'Imagenes', 'Productoras', filename)
       if File.exist?(path)
          content_type = 'image/jpg'
          image = new_image(path, filename, content_type)
         producer.image = image
       end

       producer.save!
      end


      venue1 = Venue.create(
        name:"Tridenta",
        description: "Bar de fabrica con un gran patio abierto y salón cerrado para disfrutar de buena música, buena comida y mejores cervezas. Todas nuestras cervezas y comidas son elaboradas en el lugar a la vista de quién nos acompañe.",
        location_attributes: {
          zip_code: "5500",
          street: "Olascoaga",
          city: "Capital",
          latitude: "-32.88042883193109",
          longitude: "-68.8516026751349",
          number: "1783",
          country: "Argentina",
          province: "Mendoza",
        })

      venue2 = Venue.create(name:"Luna Park",
        description: "El Luna Park es un tradicional estadio cubierto de Buenos Aires, Argentina, donde se realizan actividades artísticas y deportivas, fundado por Ismael Pace y José Lectoure en 1931",
        location_attributes: {
          zip_code: "C1106",
          street: "Av. Eduardo Madero",
          city: "Comuna 1",
          latitude: "-34.60217641615085",
          longitude: "-58.36973861326939",
          number: "470",
          country: "Argentina",
          province: "Buenos Aires",
        })


      venue3 = Venue.create(name:"Auditorio Ángel Bustelo",
        description: "El Auditorio Ángel Bustelo es un centro de espectáculos ubicado en la Ciudad de Mendoza, Argentina, en el denominado Barrio Cívico y forma parte del Centro de Congresos y Exposiciones Gobernador Emilio Civit",
        location_attributes: {
          zip_code: "5500",
          street: "Virgen del Carmen de Cuyo",
          city: "Capital",
          latitude: "-32.89806635814529",
          longitude: "-68.85010249275496",
          number: "610",
          country: "Argentina",
          province: "Mendoza",
        })

        venue4 = Venue.create(
          name: "Teatro Colón",
          description: "El Teatro Colón es un teatro de ópera de Buenos Aires considerado uno de los cinco mejores del mundo por la acústica. Es un edificio con más de 100 años de historia y una rica tradición artística.",
          location_attributes: {
            zip_code: "C1063",
            street: "Cerrito",
            city: "Comuna 1",
            latitude: "-34.60145621632879",
            longitude: "-58.3857798574496",
            number: "628",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )
        
        venue5 = Venue.create(
          name: "Estadio Monumental",
          description: "El Estadio Monumental es el estadio del Club Atlético River Plate en Buenos Aires. Es uno de los estadios más icónicos de Argentina y ha sido sede de eventos deportivos y conciertos de renombre.",
          location_attributes: {
            zip_code: "C1428",
            street: "Av. Pres. Figueroa Alcorta",
            city: "Comuna 1",
            latitude: "-34.54500182387441",
            longitude: "-58.454702153696195",
            number: "7597",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )
        
        venue6 = Venue.create(
          name: "Teatro Gran Rex",
          description: "El Teatro Gran Rex es un teatro y sala de conciertos ubicado en Buenos Aires. Ha albergado actuaciones de músicos locales e internacionales y es conocido por su excelente acústica.",
          location_attributes: {
            zip_code: "C1011",
            street: "Av. Corrientes",
            city: "Comuna 1",
            latitude: "-34.60480149464147",
            longitude: "-58.38205598885234",
            number: "857",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )

        venue7 = Venue.create(
          name: "Estadio Monumental",
          description: "El Estadio Monumental es un estadio de fútbol en Buenos Aires, Argentina, donde se celebran importantes eventos deportivos y conciertos.",
          location_attributes: {
            zip_code: "C1428",
            street: "Av. Figueroa Alcorta",
            city: "Comuna 1",
            latitude: "-34.545775",
            longitude: "-58.452760",
            number: "7597",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )
        
        venue8 = Venue.create(
          name: "Teatro Opera",
          description: "El Teatro Opera es un teatro histórico en Buenos Aires, Argentina, que ha sido un escenario para una variedad de actuaciones en vivo.",
          location_attributes: {
            zip_code: "C1061",
            street: "Av. Corrientes",
            city: "Comuna 1",
            latitude: "-34.608276",
            longitude: "-58.394451",
            number: "860",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )
        
        venue9 = Venue.create(
          name: "Teatro Gran Splendid",
          description: "El Teatro Gran Splendid es una famosa librería ubicada en un antiguo teatro en Buenos Aires, Argentina. Los visitantes pueden explorar libros en un entorno teatral impresionante.",
          location_attributes: {
            zip_code: "C1010",
            street: "Av. Santa Fe",
            city: "Comuna 1",
            latitude: "-34.595189",
            longitude: "-58.389042",
            number: "1860",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )
        
        venue10 = Venue.create(
          name: "Estadio Único de La Plata",
          description: "El Estadio Único de La Plata es un estadio en La Plata, Argentina, utilizado para eventos deportivos y conciertos. Es conocido por su arquitectura distintiva.",
          location_attributes: {
            zip_code: "B1900",
            street: "Calle 25",
            city: "Buenos Aires",
            latitude: "-34.921869",
            longitude: "-57.995502",
            number: "1675",
            country: "Argentina",
            province: "Buenos Aires",
          }
        )
        
        venue11 = Venue.create(
          name: "Teatro Solís",
          description: "El Teatro Solís es un teatro histórico en Montevideo, Uruguay, que alberga una variedad de actuaciones culturales y artísticas.",
          location_attributes: {
            zip_code: "11100",
            street: "Calle Buenos Aires",
            city: "Departamento de Montevideo",
            latitude: "-34.906498",
            longitude: "-56.194155",
            number: "470",
            country: "Uruguay",
            province: "Departamento de Montevideo",
          }
        )
        
        venue12 = Venue.create(
          name: "Teatro de la Ciudad",
          description: "El Teatro de la Ciudad es un teatro en México City, México, que presenta una amplia gama de eventos culturales y teatrales.",
          location_attributes: {
            zip_code: "06300",
            street: "Av. Donceles",
            city: "Ciudad de México",
            latitude: "19.434012",
            longitude: "-99.140388",
            number: "97",
            country: "México",
            province: "Ciudad de México",
          }
        )
        
        venue13 = Venue.create(
          name: "Auditorio Nacional",
          description: "El Auditorio Nacional es un importante centro de espectáculos en Ciudad de México, México, que acoge conciertos y eventos en vivo de alto perfil.",
          location_attributes: {
            zip_code: "06500",
            street: "Paseo de la Reforma",
            city: "Ciudad de México",
            latitude: "19.425032",
            longitude: "-99.180609",
            number: "110",
            country: "México",
            province: "Ciudad de México",
          }
        )
        
        venue14 = Venue.create(
          name: "Palacio de los Deportes",
          description: "El Palacio de los Deportes es un recinto deportivo y de entretenimiento en Ciudad de México, México, que alberga eventos deportivos y conciertos.",
          location_attributes: {
            zip_code: "15090",
            street: "Viaducto Río Piedad",
            city: "Ciudad de México",
            latitude: "19.400445",
            longitude: "-99.106376",
            number: "9",
            country: "México",
            province: "Ciudad de México",
          }
        )
        
        venue15 = Venue.create(
          name: "Foro Sol",
          description: "El Foro Sol es un estadio en Ciudad de México, México, utilizado para eventos deportivos y conciertos. Es uno de los estadios más grandes de América Latina.",
          location_attributes: {
            zip_code: "08400",
            street: "Viaducto Río Piedad",
            city: "Ciudad de México",
            latitude: "19.404725",
            longitude: "-99.090733",
            number: "504",
            country: "México",
            province: "Ciudad de México",
          }
        )

        venue16 = Venue.create(
          name: "Nave Cultural",
          description: "La Nave Cultural es un espacio cultural en Mendoza que alberga una variedad de eventos artísticos y culturales, desde conciertos hasta exposiciones de arte.",
          location_attributes: {
            zip_code: "5500",
            street: "Av. España",
            city: "Capital",
            latitude: "-32.899620",
            longitude: "-68.837873",
            number: "430",
            country: "Argentina",
            province: "Mendoza",
          }
        )
        
        venue17 = Venue.create(
          name: "Arena Maipú",
          description: "Arena Maipú es un centro de eventos en Maipú, Mendoza, donde se realizan conciertos, exposiciones y otros espectáculos en vivo.",
          location_attributes: {
            zip_code: "5515",
            street: "Ruta 20",
            city: "Maipú",
            latitude: "-32.945080",
            longitude: "-68.761327",
            number: "2245",
            country: "Argentina",
            province: "Mendoza",
          }
        )
        
        venue18 = Venue.create(
          name: "Plaza Independencia",
          description: "La Plaza Independencia es una plaza histórica en el centro de Mendoza, conocida por su belleza y su uso para eventos al aire libre y actividades culturales.",
          location_attributes: {
            zip_code: "5500",
            street: "Sarmiento",
            city: "Capital",
            latitude: "-32.888489",
            longitude: "-68.818592",
            number: "350",
            country: "Argentina",
            province: "Mendoza",
          }
        )

        venue19 = Venue.create(
          name: "Espacio Trapiche",
          description: "Espacio Trapiche es una bodega en Mendoza que a menudo organiza eventos relacionados con el vino, como degustaciones y festivales.",
          location_attributes: {
            zip_code: "5517",
            street: "Costa Flores",
            city: "Capital",
            latitude: "-32.973944",
            longitude: "-68.787981",
            number: "1",
            country: "Argentina",
            province: "Mendoza",
          }
        )

        venue20 = Venue.create(
          name: "Museo Fundacional",
          description: "El Museo Fundacional es un museo en Mendoza que presenta la historia y la cultura de la ciudad, además de albergar eventos y exposiciones.",
          location_attributes: {
            zip_code: "5500",
            street: "Pedro Molina",
            city: "Capital",
            latitude: "-32.883973",
            longitude: "-68.821511",
            number: "1820",
            country: "Argentina",
            province: "Mendoza",
          }
        )

        venue_river = Venue.create(
          name: "Estadio River Plate",
          description: "El Estadio Monumental es un recinto deportivo ubicado en la intersección de las avenidas Figueroa Alcorta y Udaondo del barrio de Belgrano, Buenos Aires, Argentina. Es propiedad del Club Atlético River Plate y fue inaugurado el 26 de mayo de 1938 por el presidente Antonio Vespucio Liberti, quien decidió su construcción. El estadio cuenta con una capacidad de 84,567 espectadores después de las remodelaciones concluidas en 2023. Es el estadio de fútbol con mayor capacidad de Argentina y de América. Además, es el recinto donde Argentina disputa sus partidos de local. El estadio ha sido sede de varios eventos trascendentes, como la final de la Copa Mundial de la FIFA 1978, cuatro finales de la Copa América (1946, 1959, 1987 y 2011), y finales de la Copa Libertadores, la Copa Sudamericana y la Recopa Sudamericana.",
          location_attributes: {
            zip_code: "C1428",
            street: "Avenida Presidente Figueroa Alcorta",
            city: "Comuna 13",
            latitude: "-34.54529950000001",
            longitude: "-58.4497634",
            number: "7597",
            country: "Argentina",
            province: "Buenos Aires",
          },
          links_attributes: [{"title":"Página del Club","url":"https://www.cariverplate.com.ar/"}] )

          Venue.all.each do |venue|
            filename = "#{venue.name}.png"
            path = Rails.root.join('MockData', 'Imagenes', 'EspaciosDeEventos', filename)
            next unless File.exist?(path)
  
            content_type = 'image/png'
            image = new_image(path, filename, content_type)
            venue.update!(image:)
          end

        [
          {
            name: 'Noche de Flamenco',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Sumérgete en el apasionante mundo del flamenco con una noche llena de baile y música en vivo.'
          },
          {
            name: 'Concierto de Rock Progresivo',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Experimenta la complejidad y la innovación del rock progresivo en un concierto inolvidable.'
          },
          {
            name: 'Tarde de Boleros',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Déjate llevar por la pasión de los boleros en una tarde romántica llena de melodías conmovedoras.'
          },
          {
            name: 'Festival de Electrónica en la Playa',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Disfruta de la música electrónica en un escenario de playa con los mejores DJ internacionales.'
          },
          {
            name: 'Concierto de Música Latina',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Baila al ritmo de la música latina con una noche de reguetón, salsa y más géneros latinos.'
          },
          {
            name: 'Noche de Ópera',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Experimenta la majestuosidad de la ópera en una noche que te llevará a mundos de emoción y drama.'
          },
          {
            name: 'Fiesta de Ska en la Calle',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: '¡Baila y diviértete en una fiesta callejera con la mejor música ska en vivo!'
          },
          {
            name: 'Concierto de Rap Nacional',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Celebra el rap nacional con actuaciones en vivo de los mejores artistas de la escena.'
          },
          {
            name: 'Festival de Reggaetón',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Perrea y disfruta de la música reggaetón en un festival lleno de ritmo y sensualidad.'
          },
          {
            name: 'Concierto de Metal Sinfónico',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Sumérgete en el mundo épico del metal sinfónico con un concierto lleno de poder y melodía.'
          },
          {
            name: 'Noche de R&B',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Disfruta de una noche de música R&B sensual y romántica que te hará mover el cuerpo.'
          },
          {
            name: 'Concierto de Pop Rock',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Baila y canta con las mejores canciones del pop rock en un concierto lleno de energía y diversión.'
          },
          {
            name: 'Festival de Country al Aire Libre',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Vive la auténtica experiencia del country en un festival al aire libre con música en vivo y actividades.'
          },
          {
            name: 'Noche de Tango en Buenos Aires',
            datetime: (DateTime.now + rand(1..6).months).to_s,
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Déjate llevar por el tango en una noche romántica en la capital del tango, Buenos Aires.'
          }
        ].each do |event|
        evento = Event.find_or_create_by(event)
        
        [
          {
              rating: (rand(9) + 1) * 0.5,
              description: "Este artista es simplemente excepcional. Su música me transporta a otro mundo.",
              user_id: User.order("RANDOM()").first.id,
              event_id: evento.id,
              reviewable_id: evento.artist.id,
              reviewable_type: "Artist"
          },
          {
              rating: (rand(9) + 1) * 0.5,
              description: "No puedo dejar de escuchar las canciones de este artista. Cada una es una obra maestra.",
              user_id: User.order("RANDOM()").first.id,
              event_id: evento.id,
              reviewable_id: evento.artist.id,
              reviewable_type: "Artist"
          },
          {
              rating: (rand(9) + 1) * 0.5,
              description: "Increíble talento. Las actuaciones en vivo de este artista son inolvidables.",
              user_id: User.order("RANDOM()").first.id,
              event_id: evento.id,
              reviewable_id: evento.artist.id,
              reviewable_type: "Artist"
          },
          {
              rating: (rand(9) + 1) * 0.5,
              description: "Si estás buscando música que llegue al corazón, no busques más. Este artista es asombroso.",
              user_id: User.order("RANDOM()").first.id,
              event_id: evento.id,
              reviewable_id: evento.artist.id,
              reviewable_type: "Artist"
          },
          {
              rating: (rand(9) + 1) * 0.5,
              description: "Las canciones de este artista tienen una calidad y profundidad impresionantes. No puedo tener suficiente.",
              user_id: User.order("RANDOM()").first.id,
              event_id: evento.id,
              reviewable_id: evento.artist.id,
              reviewable_type: "Artist"
          }
        ].each do |review|
          Review.find_or_create_by(review)
        end
        
        [
      {
        rating: (rand(9) + 1) * 0.5,
        description: "La productora superó todas mis expectativas. Organizaron el evento de manera impecable y la calidad del sonido fue excepcional.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.producer.id,
        reviewable_type: "Producer"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "Trabajar con esta productora fue una experiencia increíble. Se preocuparon por cada detalle y el resultado fue un evento espectacular.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.producer.id,
        reviewable_type: "Producer"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "¡Recomendaría esta productora a cualquiera que busque un evento musical de alta calidad! Su profesionalismo y creatividad son excepcionales.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.producer.id,
        reviewable_type: "Producer"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "Estamos muy agradecidos por el trabajo de esta productora. Hicieron que nuestro evento musical fuera un verdadero éxito. ¡No podríamos estar más contentos!",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.producer.id,
        reviewable_type: "Producer"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "La productora demostró un gran compromiso con nuestro evento y se aseguró de que todo saliera a la perfección. Definitivamente los contrataríamos nuevamente.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.producer.id,
        reviewable_type: "Producer"
      }
    ].each do |review|
              Review.find_or_create_by(review)
            end


            [
      {
        rating: (rand(9) + 1) * 0.5,
        description: "Este lugar de eventos es simplemente asombroso. La acústica es perfecta y la atmósfera es inigualable. Fue el escenario perfecto para el concierto.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.venue.id,
        reviewable_type: "Venue"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "Increíble lugar para conciertos. La ubicación es conveniente y el personal es amable y servicial. Sin duda, volveremos.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.venue.id,
        reviewable_type: "Venue"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "El espacio es espacioso y cómodo, y la vista desde cualquier asiento es excelente. La experiencia de concierto fue inolvidable gracias a este lugar.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.venue.id,
        reviewable_type: "Venue"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "La calidad del sonido en este lugar es excepcional. Pudimos disfrutar del concierto sin perder ningún detalle de la música. ¡Altamente recomendado!",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.venue.id,
        reviewable_type: "Venue"
      },
      {
        rating: (rand(9) + 1) * 0.5,
        description: "El personal de este lugar de eventos hizo que nuestra experiencia fuera suave y agradable. Nos sentimos bienvenidos y bien atendidos durante todo el concierto.",
        user_id: User.order("RANDOM()").first.id,
        event_id: evento.id,
        reviewable_id: evento.venue.id,
        reviewable_type: "Venue"
      }
    ].each do |review|
              Review.find_or_create_by(review)
            end
                    
          end

      # Crear comentarios y asociarlos a eventos
      comments = [
          "¡Increíble actuación, no puedo creer lo bueno que estuvo!",
          "La energía en este evento es incomparable, ¡lo amé!",
          "Mis oídos están agradecidos, la música fue sublime.",
          "Definitivamente, este concierto superó mis expectativas.",
          "¡Qué noche épica! La banda estuvo en su mejor momento.",
          "El ambiente musical era mágico, una experiencia inolvidable.",
          "Cada nota resonó en mi corazón, simplemente maravilloso.",
          "¡Bravo! Los artistas se lucieron en el escenario.",
          "Este evento musical es la razón por la que amo la música en vivo.",
          "Increíble variedad de géneros, todos brillaron en el escenario.",
          "Mis pies no dejaron de bailar, la mejor fiesta musical.",
          "Desde la primera canción hasta el bis, no quería que terminara.",
          "Gracias a los artistas por compartir su talento, ¡fue asombroso!",
          "Un concierto que quedará grabado en mi memoria para siempre.",
          "La combinación de luces y sonido fue impresionante, un espectáculo completo."
      ]

      Event.all.each do |event|
        # Genera un número aleatorio de comentarios para cada evento (entre 1 y 5)
        num_comments = rand(1..9)

        num_comments.times do
          Comment.create!(
            body: comments[rand(0..14)],
            user_id: User.order("RANDOM()").first.id, # Asigna un usuario aleatorio
            event_id: event.id
          )
        end
      end
  end

  desc "like [Comment,Video]"
  task likes: :environment do
    User.all.each do |user|
      [Comment,Video].each do |likeable_type|
        random = rand(1..likeable_type.all.size)
        likeable_type.limit(random).each do |likeable|
          # Verifica si el usuario ya ha dado like a esta instancia
          next if Like.exists?(user_id: user.id, likeable_id: likeable.id, likeable_type: likeable_type.to_s)
    
          # Si no ha dado like, crea uno
          Like.create!(
            user_id: user.id,
            likeable: likeable
          )
        end
      end
    end
  end

  desc "Edit created_at attribute for records in the last 6 months"
  task edit_created_at: :environment do
    # Calcula la fecha hace 6 meses
    six_months_ago = 6.months.ago
  
    # Encuentra y actualiza Eventos
    events_to_update = Event.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(events_to_update)
  
    # Encuentra y actualiza Likes
    likes_to_update = Like.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(likes_to_update)
  
    # Encuentra y actualiza Comentarios
    comments_to_update = Comment.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(comments_to_update)
  
    # Encuentra y actualiza Reseñas
    reviews_to_update = Review.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(reviews_to_update)
  
    # Encuentra y actualiza Artistas
    artists_to_update = Artist.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(artists_to_update)

    # Encuentra y actualiza Users
    artists_to_update = User.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(artists_to_update)

    # Encuentra y actualiza Venues
    venues_to_update = Venue.where("created_at >= ?", six_months_ago)
    update_created_at_for_records(venues_to_update)
  
    puts "Updated created_at for records in multiple entities."
  end

  desc "Update permissions in roles"
  task update_role_and_trust_levels_permissions: :environment do 
    
    # Buscar el rol por nombre
    admin_role = Role.find_by(name: "admin")
    moderator_role = Role.find_by(name: "moderator")
    l1_trust_level = Role.find_by(name: "level_1")
    l2_trust_level = Role.find_by(name: "level_2")
    l3_trust_level = Role.find_by(name: "level_3")


    videos_permission = Permission.where(subject_class: "VideosController").pluck(:id)
    versions_permission = Permission.where(subject_class: "VersionsController").pluck(:id)
    venues_permission = Permission.where(subject_class: "VenuesController").pluck(:id)
    reviews_permission = Permission.where(subject_class: "ReviewsController").pluck(:id)
    comments_permission = Permission.where(subject_class: "CommentsController").pluck(:id)
    artist_permission = Permission.where(subject_class: "ArtistsController").pluck(:id)
    event_permission = Permission.where(subject_class: "EventsController").pluck(:id)
    producer_permission = Permission.where(subject_class: "ProducersController").pluck(:id)
    reports_controller_permission = Permission.where(subject_class: "ReportsController").pluck(:id)

    ## L3 Actualizar
    artist_permission_update = Permission.where(subject_class: "ArtistsController", action: "update").pluck(:id)
    event_permission_update = Permission.where(subject_class: "EventsController", action: "update").pluck(:id)
    producer_permission_update = Permission.where(subject_class: "ProducersController", action: "update").pluck(:id)
    venues_permission_update = Permission.where(subject_class: "VenuesController", action: "update").pluck(:id)

    comments_permission_l1 = Permission.where(subject_class: "CommentsController", action: "create").pluck(:id)
    create_permission_l2 = Permission.where(action: "create").where.not("subject_class LIKE ?", "%Admin%").pluck(:id)
    report_permission_l2 = Permission.where(action: "report").pluck(:id)
    videos_permission_l2 = Permission.where(subject_class: "VideosController", action: "create").pluck(:id)
    update_persmissions_l3 = artist_permission_update +
                             event_permission_update +
                             producer_permission_update +
                             venues_permission_update

    ## Asignacion de permisos
    admin_permissions = Permission.all.pluck(:id)
    moderator_permissions = videos_permission +
                            versions_permission +
                            venues_permission +
                            reviews_permission +
                            comments_permission +
                            artist_permission +
                            event_permission +
                            producer_permission +
                            reports_controller_permission
    level_1_permissions = comments_permission_l1
    level_2_permissions = level_1_permissions + report_permission_l2 + videos_permission_l2 + create_permission_l2
    level_3_permissions = level_2_permissions + update_persmissions_l3


    # Actualizar los permission_ids
    admin_role.update(permission_ids: admin_permissions) if admin_role.present?
    moderator_role.update(permission_ids: moderator_permissions) if moderator_role.present?

    l1_trust_level.update(permission_ids:level_1_permissions) if l1_trust_level.present?
    l2_trust_level.update(permission_ids:level_2_permissions) if l2_trust_level.present?
    l3_trust_level.update(permission_ids:level_3_permissions) if l3_trust_level.present?
  end

  desc "events_to_show pasados y futuros"
  task events_to_show: :environment do

    # Generos Musicales asociados
    pop_genre = Genre.find_by(name: "Pop")
    country_genre = Genre.find_by(name: "Country")
    rock_genre = Genre.find_by(name: "Rock")
    hiphop_genre = Genre.find_by(name: "Hip Hop")
    rb_genre = Genre.find_by(name: "R&B")
    metal_genre = Genre.find_by(name: "Metal")
    salsa_genre = Genre.find_by(name: "Salsa")
    reggaeton_genre = Genre.find_by(name: "Reguetón")

    # Productoras
    df_producer = Producer.find_by( name: 'DF Entertainment')
    df_producer.update( genre_ids: [pop_genre.id, rock_genre.id, hiphop_genre.id, rb_genre.id, metal_genre.id, salsa_genre.id, reggaeton_genre.id] )
    universal_producer = Producer.find_by( name: 'Universal Music Group')
    universal_producer.update({ genre_ids: [pop_genre.id, rock_genre.id, hiphop_genre.id, rb_genre.id]} )
   
   # Espacios de eventos
    venue_river = Venue.find_by( name: "Estadio River Plate" )

    # Artistas
    taylor_artist = Artist.find_by(name: 'Taylor Swift')
    taylor_artist.update(genre_ids: [pop_genre.id,country_genre.id])
    roger_artist = Artist.find_by(name: 'Roger Waters')
    roger_artist.update(genre_ids: [rock_genre.id])
   
    # Eventos
    Event.create({
          name: 'Gira mundial ‘The Eras Tour’ de Taylor Swift',
          datetime: ("2023-11-09T19:00:00.000Z"),
          artist_id: taylor_artist.id,
          producer_id: universal_producer.id,
          venue_id: venue_river.id,
          description: "Taylor Swift se presenta en el estadio River Plate de Buenos Aires, Argentina, como parte de su gira mundial “The Eras Tour” . Durante su presentación, Taylor Swift interpreta canciones de su último álbum “Midnights” y algunos de sus éxitos anteriores . Además, hace un guiño a su romance con Travis Kelce, ala cerrada de los Kansas City Chiefs, cambiando la letra de su canción “Karma”.",
          links_attributes: [{"title":"Entradas","url":"https://www.allaccess.com.ar/list/taylor%20swift"}]
          } )
  
    Event.create({
          name: 'Roger Waters en Argentina',
          datetime: ("2023-11-21T21:00:00.000Z"),
          artist_id: roger_artist.id,
          producer_id: df_producer.id,
          venue_id: venue_river.id,
          description: "“This Is Not a Drill” se plantea como un show altamente conceptual de principio a fin, donde canciones provenientes de The Wall, The Dark Side of the Moon (que acaba de cumplir 50 años), Animals y Wish You Were Here confluyen con los temas solistas más recientes del artista incluyendo su lanzamiento The Bar.",
          links_attributes: [{"title":"Entradas","url":"https://www.allaccess.com.ar/event/roger-waters"}]
          })
  end
  
  # Esta función actualiza el atributo created_at para un conjunto de registros
  def update_created_at_for_records(records)
    records.each do |record|
      random_date = 6.months.ago + rand(6.months)
      record.update(created_at: random_date)
    end
  end

  def new_image(path, filename, content_type)
    image = Image.new
    image.file.attach(io: File.open(path), filename: filename, content_type: content_type)
    image
  end
end