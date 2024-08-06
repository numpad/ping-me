defmodule PingMe.Cldr do
  use Cldr,
    locales: ["en", "de"],
    default_locale: "en",
    force_locale_download: Mix.env() == :prod
end

