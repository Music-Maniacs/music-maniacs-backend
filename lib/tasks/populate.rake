namespace :populate do
  desc "Populate database with roles and permissions"
  task roles_and_permissions: :environment do
    # por ahora queda así bien tranqui a modo de ejemplo, después se puede mejorar, la idea acá es crear todos los roles
    # que van si o si como admin y moderador y los CRUD de todos los controllers para las permissions
    # Create some roles
    admin_role = Role.find_or_create_by!(name: 'admin')
    user_role = Role.find_or_create_by!(name: 'user')
    moderator_role = Role.find_or_create_by!(name: 'moderator')
    guest_role = Role.find_or_create_by!(name: 'guest')


    # Create some trust levels
    default_trust_level = TrustLevel.find_or_create_by!(name: 'level 1', order: 1, days_visited: 0, viewed_events: 0, likes_received: 0, likes_given: 0, comments_count: 0)
    trusted_member_level = TrustLevel.find_or_create_by!(name: 'level 2', order: 2, days_visited: 30, viewed_events: 10, likes_received: 50, likes_given: 100, comments_count: 20)
    vip_level = TrustLevel.find_or_create_by!(name: 'level_3', order: 3, days_visited: 60, viewed_events: 20, likes_received: 100, likes_given: 200, comments_count: 40)

    # Create some permissions
    permission1 = Permission.find_or_create_by!(name: 'Ver usuarios', action: 'Index', subject_class: 'User')
    permission2 = Permission.find_or_create_by!(name: 'Ver info usuario', action: 'Show', subject_class: 'User')
    permission3 = Permission.find_or_create_by!(name: 'Crear usuario', action: 'Create', subject_class: 'User')
    permission4 = Permission.find_or_create_by!(name: 'Editar usuario', action: 'Update', subject_class: 'User')
    permission5 = Permission.find_or_create_by!(name: 'Eliminar usuario', action: 'Delete', subject_class: 'User')
    
    permission6 = Permission.find_or_create_by!(name: 'Ver artista', action: 'Index', subject_class: 'Artist')
    permission7 = Permission.find_or_create_by!(name: 'Ver info artista', action: 'Show', subject_class: 'Artist')
    permission8 = Permission.find_or_create_by!(name: 'Crear artista', action: 'Create', subject_class: 'Artist')
    permission9 = Permission.find_or_create_by!(name: 'Editar artista', action: 'Update', subject_class: 'Artist')
    permission10 = Permission.find_or_create_by!(name: 'Eliminar artista', action: 'Delete', subject_class: 'Artist')

    permission11 = Permission.find_or_create_by!(name: 'Ver genero', action: 'Index', subject_class: 'Genre')
    permission12 = Permission.find_or_create_by!(name: 'Ver info genero', action: 'Show', subject_class: 'Genre')
    permission13 = Permission.find_or_create_by!(name: 'Crear genero', action: 'Create', subject_class: 'Genre')
    permission14 = Permission.find_or_create_by!(name: 'Editar genero', action: 'Update', subject_class: 'Genre')
    permission15 = Permission.find_or_create_by!(name: 'Eliminar genero', action: 'Delete', subject_class: 'Genre')

    permission16 = Permission.find_or_create_by!(name: 'Ver esapcio de eventos', action: 'Index', subject_class: 'Venue')
    permission17 = Permission.find_or_create_by!(name: 'Ver info esapcio de evento', action: 'Show', subject_class: 'Venue')
    permission18 = Permission.find_or_create_by!(name: 'Crear esapcio de eventos', action: 'Create', subject_class: 'Venue')
    permission19 = Permission.find_or_create_by!(name: 'Editar esapcio de eventos', action: 'Update', subject_class: 'Venue')
    permission20 = Permission.find_or_create_by!(name: 'Eliminar esapcio de eventos', action: 'Delete', subject_class: 'Venue')

    permission21 = Permission.find_or_create_by!(name: 'Ver eventos', action: 'Index', subject_class: 'Event')
    permission22 = Permission.find_or_create_by!(name: 'Ver info evento', action: 'Show', subject_class: 'Event')
    permission23 = Permission.find_or_create_by!(name: 'Crear eventos', action: 'Create', subject_class: 'Event')
    permission24 = Permission.find_or_create_by!(name: 'Editar eventos', action: 'Update', subject_class: 'Event')
    permission25 = Permission.find_or_create_by!(name: 'Eliminar eventos', action: 'Delete', subject_class: 'Event')

   # Asocia permisos con roles y niveles de confianza
   admin_role.permissions << [permission1,permission2,permission3,permission4,permission5,permission6,permission7,permission8,permission9,permission10,permission11,permission12,permission13,permission14,permission15,permission16,permission17,permission18,permission19,permission20,permission21,permission22,permission23,permission24,permission25]
   user_role.permissions << [permission1,permission6,permission11,permission16,permission21,]
   moderator_role.permissions << [permission1, permission2, permission3, permission6, permission7, permission8, permission9, permission10]
   guest_role.permissions << [permission1, permission2, permission3]

   # Asocia permisos con niveles de confianza (si es necesario)
   default_trust_level.permissions << [permission1, permission2, permission3]
   trusted_member_level.permissions << [permission1, permission2, permission3, permission6, permission7, permission8, permission9, permission10]
   vip_level.permissions << [permission1, permission2, permission3, permission6, permission7, permission8, permission9, permission10]

    admin_role.save
    user_role.save
    default_trust_level.save
    trusted_member_level.save
    vip_level.save

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

    PenaltyThreshold.find_or_create_by(penalty_score: 50, days_blocked: 15)
    PenaltyThreshold.find_or_create_by(penalty_score: 100, days_blocked: 25)
    PenaltyThreshold.find_or_create_by(penalty_score: 150, days_blocked: 35)

    [{ email: 'tomasespin12@gmail.com', username: 'tomas1646', full_name: 'Tomas Espinosa' },
     { email: 'jokinabarzua@hotmail.com', username: 'jokinAbarzua', full_name: 'Jokin Abarzua' },
     { email: 'ezesalas@gmail.com', username: 'ezeSalas', full_name: 'Eze Salas' },
     { email: 'octalcalde@gmail.com', username: 'octavio', full_name: 'Octa Alcalde' },
     { email: 'lucasmiranda@gmail.com', username: 'lucarMiranda', full_name: 'Lucas Miranda' }].each do |user|

        next if User.find_by('email= ? OR username= ?', user[:email], user[:username]).present?

        User.create({ email: user[:email],
                      username: user[:username],
                      full_name: user[:full_name],
                      password: '123123123',
                      password_confirmation:'123123123',
                      role_id: admin_role.id })
    end

    [{ name: 'Usted Señalemelo', nationality: 'Argentina', description: 'Usted Señalemelo es una banda argentina de indie rock, formada en Mendoza. El grupo está compuesto por el vocalista y tecladista Juan Saieg, el guitarrista Gabriel "Cocó" Orozco y el baterista Lucca Beguerie Petrich.' },
     { name: 'Enanitos Verdes', nationality: 'Argentina', description: 'Los Enanitos Verdes o simplemente Enanitos Verdes, a veces abreviado EV, es una banda argentina de rock en español de Mendoza. Organizado originalmente como un trío con Marciano Cantero, Felipe Staiti y Daniel Piccolo en 1979, luego se les unieron Sergio Embrioni y Tito Dávila.' },
     { name: 'Soda Estereo', nationality: 'Argentina', description: 'Soda Stereo es una banda de rock argentina formada en 1982 por Gustavo Cerati, Zeta Bosio y Charly Alberti, ​considerada ampliamente por la crítica especializada como la banda más importante, popular e influyente del rock en español y una leyenda de la música latinoamericana.' },
     { name: 'Sui Generis', nationality: 'Argentina', description: 'Sui Generis fue una banda argentina de rock formada principalmente por Charly García (teclados, guitarra acústica, voz y composiciones) y Nito Mestre (flauta, guitarra acústica y voz), considerada como una de las más importantes de los orígenes del rock latinoamericano. Sus canciones (en particular las de sus dos primeros álbumes) se convirtieron virtualmente en himnos cantados por generaciones de argentinos, formando hoy parte del paisaje cultural nacional de ese país. Si bien a lo largo de su carrera la banda contó con otros miembros, fue el dúo García/Mestre el que quedó asociado con el nombre, y al que debieron su enorme fama posterior.' },
    ].each do |artist|
      next if Artist.find_by(name: artist[:name]).present?

        Artist.create({ name: artist[:name],
                        nationality: artist[:nationality],
                        description: artist[:description] })
     end

     [{ name: 'Maratone Studios', nationality: 'Suceia', description: 'Maratone es una compañía de producción musical y fue iniciada por dos productores musicales y compositores, Max Martin y Tom Talomaa. Con sede en Estocolmo, Suecia, se inició en enero de 2001 después del cierre de Cheiron Studios.' },
      { name: 'Custard Records', nationality: 'Estados Unidos de América', description: 'Custard Records es un sello discográfico estadounidense, mejor conocido por su éxito con el cantautor inglés James Blunt. El sello está dirigido por la ex miembro de 4 Non Blondes, Linda Perry, y tiene una asociación con la división Atlantic Records de Warner Music Group.' },
      { name: 'American Recordings', nationality: 'Estados Unidos de América', description: 'American Recordings es un sello discográfico creado por el productor Rick Rubin en 1988. Su sede se encuentra en Los Ángeles. Entre sus artistas más famosos se encuentran Slayer, The Black Crowes, Danzig, Johnny Cash y System of a Down.' },
     ].each do |producer|
       next if Producer.find_by(name: producer[:name]).present?
 
       Producer.create({ name: producer[:name],
                         nationality: producer[:nationality],
                         description: producer[:description] })
      end


      venue1 = Venue.create(
        name:"Tridenta",
        description: "Bar de fabrica con un gran patio abierto y salón cerrado para disfrutar de buena música, buena comida y mejores cervezas. Todas nuestras cervezas y comidas son elaboradas en el lugar a la vista de quién nos acompañe.",
        location_attributes: {
          zip_code: "5500",
          street: "Olascoaga",
          department: "Mendoza",
          locality: "Mendoza",
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
          department: "CABA",
          locality: "CABA",
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
          department: "Mendoza",
          locality: "Mendoza",
          latitude: "-32.89806635814529",
          longitude: "-68.85010249275496",
          number: "610",
          country: "Argentina",
          province: "Mendoza",
        })

        [
          {
            name: 'Domingo de música',
            datetime: '2023-09-14T19:21:00.000Z',
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Disfruta de una emocionante tarde de música en vivo con artistas sorpresa. ¡No te lo pierdas!'
          },
          {
            name: 'Gira federal',
            datetime: '2023-09-18T19:21:00.000Z',
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: '¡La gira federal llega a tu ciudad con un espectáculo musical imperdible!'
          },
          {
            name: 'Concierto en Vivo',
            datetime: '2024-09-12T19:21:00.000Z',
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Una noche llena de energía y música en vivo que te hará vibrar de emoción.'
          },
          {
            name: 'Noche de Música en Vivo',
            datetime: '2023-10-07T19:21:00.000Z',
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Únete a nosotros para una emocionante noche llena de música en vivo y entretenimiento.'
          },
          {
            name: 'Presentacion musical',
            datetime: '2023-12-12T19:21:00.000Z',
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Una presentación musical especial que te llevará a un viaje a través de diferentes estilos musicales.'
          },
          {
            name: 'Noche de Jazz',
            datetime: '2023-09-28T19:21:00.000Z',
            artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
            description: 'Disfruta de una noche de jazz en un ambiente relajado y sofisticado.'
          },
          {
    name: 'Noche de Rock en Vivo',
    datetime: '2023-10-15T20:00:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Una noche llena de potente rock en vivo que te hará vibrar. ¡Únete a nosotros y sé parte de la historia del rock!'
  },
  {
    name: 'Fiesta de Reggae bajo las Estrellas',
    datetime: '2023-11-05T21:30:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Sumérgete en el ritmo relajante del reggae en una fiesta al aire libre bajo las estrellas. ¡Vive la buena vibra!'
  },
  {
    name: 'Concierto de Orquesta Sinfónica',
    datetime: '2023-11-20T19:00:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Una velada elegante y emocionante con una interpretación magistral de la orquesta sinfónica. Una experiencia musical única.'
  },
  {
    name: 'Noche de Hip-Hop Urbano',
    datetime: '2023-12-03T22:00:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Descubre la cultura del hip-hop en una noche llena de ritmo, baile y líricas impactantes. ¡El hip-hop toma el escenario!'
  },
  {
    name: 'Festival de Indie Rock Alternativo',
    datetime: '2024-01-15T17:00:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Un festival para los amantes del indie rock alternativo. Bandas emergentes y sonidos vanguardistas te esperan.'
  },
  {
    name: 'Tarde de Música Clásica',
    datetime: '2024-02-05T15:30:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Disfruta de una tarde de música clásica interpretada por virtuosos músicos en un entorno íntimo y acogedor.'
  },
  {
    name: 'Concierto de Pop Latino',
    datetime: '2024-03-10T20:30:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Baila y canta al ritmo de las mejores canciones del pop latino en un concierto lleno de energía y pasión.'
  },
  {
    name: 'Festival de Folk Tradicional',
    datetime: '2024-04-22T18:00:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Explora la riqueza de la música folk tradicional de diferentes culturas en este festival lleno de autenticidad y tradición.'
  },
  {
    name: 'Noche de Blues en la Ciudad',
    datetime: '2024-05-07T21:00:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Deja que el blues te atrape en una noche de música emocional y expresiva en el corazón de la ciudad.'
  },
  {
    name: 'Concierto de Piano Solo',
    datetime: '2024-06-18T19:30:00.000Z',
    artist_id: Artist.order("RANDOM()").first.id,
            producer_id: Producer.order("RANDOM()").first.id,
            venue_id: Venue.order("RANDOM()").first.id,
    description: 'Una velada íntima y conmovedora con un talentoso pianista que te llevará a través de las notas del piano.'
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
      
        
  end
end