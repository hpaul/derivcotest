defmodule Derivcotest.Messages do
  use Protobuf, from: Path.expand("../proto/messages.proto", __DIR__), use_package_names: false
end
