requires "Array::Unique" => "0.08";
requires "CPAN::Meta" => "2.142690";
requires "Class::Accessor" => "0.34";
requires "Date::Format" => "2.24";
requires "Email::Address" => "1.905";
requires "Email::Date::Format" => "1.005";
requires "File::ShareDir" => "1.102";
requires "File::Which" => "1.09";
requires "HTML::Parser" => "3.71";
requires "HTML::Template" => "2.95";
requires "IO::String" => "1.08";
requires "LWP::UserAgent" => "6.06";
requires "List::MoreUtils" => "0.33";
requires "Module::Depends" => "0.16";
requires "Parse::DebControl" => "2.005";
requires "Software::License" => "0.103010";
requires "Tie::IxHash" => "1.23";
requires "WWW::Mechanize" => "1.73";
requires "YAML" => "1.13";
requires "perl" => "5.010001";
requires "version" => "0.88";

on 'build' => sub {
  requires "ExtUtils::CChecker" => "0.10";
  requires "Module::Build" => "0.4004";
  requires "Module::Build::WithXSpp" => "0.14";
  requires "Test::Compile" => "v1.2.1";
  requires "Test::Differences" => "0.62";
  requires "Test::Exception" => "0.35";
  requires "Test::Requires" => "0.06";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "ExtUtils::CChecker" => "0.10";
  requires "Module::Build" => "0.4004";
  requires "Module::Build::WithXSpp" => "0.14";
  requires "version" => "0.88";
};
