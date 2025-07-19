:toc: macro
:toclevels: 5
:figure-caption!:

= Rspec Html Messages

toc::[]

== Features

== Requirements

. link:https://www.ruby-lang.org[Ruby].

== Setup

To install _with_ security, run:

[source,bash]
----
# 💡 Skip this line if you already have the public certificate installed.
gem cert --add <(curl --compressed --location https://undefined.io/gems.pem)
gem install rspec-html_messages --trust-policy HighSecurity
----

To install _without_ security, run:

[source,bash]
----
gem install rspec-html_messages
----

You can also add the gem directly to your project:

[source,bash]
----
bundle add rspec-html_messages
----

Once the gem is installed, you only need to require it:

[source,ruby]
----
require "rspec/html_messages"
----

== Usage

== Development

To contribute, run:

[source,bash]
----
git clone https://github.com/undefined/rspec-html_messages
cd rspec-html_messages
bin/setup
----

You can also use the IRB console for direct access to all objects:

[source,bash]
----
bin/console
----

== Tests

To test, run:

[source,bash]
----
bin/rake
----

== link:https://undefined.io/policies/license[License]

== link:https://undefined.io/policies/security[Security]

== link:https://undefined.io/policies/code_of_conduct[Code of Conduct]

== link:https://undefined.io/policies/contributions[Contributions]

== link:https://undefined.io/policies/developer_certificate_of_origin[Developer Certificate of Origin]

== link:https://undefined.io/projects/rspec-html_messages/versions[Versions]

== Credits

* Built with link:https://alchemists.io/projects/gemsmith[Gemsmith].
* Engineered by link:https://undefined.io/team/undefined[Raghu Betina].
