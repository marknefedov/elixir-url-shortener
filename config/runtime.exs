import Config
alias Vapor.Provider.{Env, Dotenv}

providers = [
  %Dotenv{},
  %Env{bindings: [mongo_string: "MONGO_STRING", base_url: "BASE_URL"]}
]

config = Vapor.load!(providers)

config :url_shortener,
  mongo_string: config.mongo_string,
  base_url: config.base_url
