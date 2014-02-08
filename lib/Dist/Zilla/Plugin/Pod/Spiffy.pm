package Dist::Zilla::Plugin::Pod::Spiffy;

use strict;
use warnings;

our $VERSION = '1.001002'; # VERSION

use Moose;
with qw/Dist::Zilla::Role::FileMunger/;
use Acme::CPANAuthors;
use namespace::autoclean -also => qr/^__/;

sub munge_file {
        my ($self, $file) = @_;
        return unless $file->name =~ /\.(?:p[lm]|t)$/;

        my $content = $file->content;
        $content =~ s/
            ^=for\s+  pod_spiffy  \s+ (?<args>.+?) (?=\n\n)
            |
            ^=begin\s+ pod_spiffy \s+ (?<args>.+?) ^=end\s+ pod_spiffy \s+\n
        / __munge_args( $+{args} ) /sexmg;

        $file->content( $content );

        return;
}

sub __munge_args {
    my $in = shift;
    $in =~ s/\s+/ /g;
    my @ins = split /\s*\|\s*/, $in;

    my $theme = 'http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons';
    my $mungings = __mungings($theme);
    my $out;
    for ( @ins ) {
        s/^\s+|\s+$//g;
        if ( s/^github\s+// ) {
            $out .= ' ' . __process_git($theme, $_);
            next;
        }
        elsif ( s/^authors?\s+// ){
            $out .= ' ' . __process_authors($theme, $_);
            next;
        }

        tr/ /_/;
        next unless $mungings->{$_};
        $out .= ' ' . $mungings->{$_};
    }

    return '' unless $out;
    return '=for html ' . $out;
}

sub __process_authors {
    my ( $theme, $authors ) = @_;

    my @authors = $authors =~ /\S+/g;
    my $out;
    my $auth = Acme::CPANAuthors->new;
    for ( map uc, @authors ) {
        my $url = $auth->avatar_url($_) || '';
        $out .= ' ' . qq{<a href="http://metacpan.org/author/$_" style="float: left; text-align: center;padding-right: 5px;">}
                . qq{<img src="$url" alt="$_" style="display: block;padding-bottom: 5px;">$_</a>};
    }

    return $out . '<br style="clear: both;">';
}

sub __process_git {
    my ( $theme, $repo ) = @_;

    return qq{<p style="background: url($theme/github.png) no-repeat left;}
        . qq{ padding-left: 120px; min-height: 61px; }
        . qq{padding-top: 30px;">$repo</p>};
}

sub __mungings {
    my $theme = shift;
    return {
        in_arrayref => qq{<img alt="" src="$theme/in-arrayref.png">},
        in_hashref  => qq{<img alt="" src="$theme/in-hashref.png">},
        in_key_value  => qq{<img alt="" src="$theme/in-key-value.png">},
        in_list  => qq{<img alt="" src="$theme/in-list.png">},
        in_no_args  => qq{<img alt="" src="$theme/in-no-args.png">},
        in_object  => qq{<img alt="" src="$theme/in-object.png">},
        in_scalar_optional
            => qq{<img alt="" src="$theme/in-scalar-optional.png">},
        in_scalar_or_arrayref
            => qq{<img alt="" src="$theme/in-scalar-or-arrayref.png">},
        in_scalar  => qq{<img alt="" src="$theme/in-scalar.png">},
        in_scalar_scalar_optional
            => qq{<img alt="" src="$theme/in-scalar-scalar-optional.png">},
        in_subref => qq{<img alt="" src="$theme/in-subref.png">},
        out_arrayref => qq{<img alt="" src="$theme/out-arrayref.png">},
        out_error_exception
            => qq{<img alt="" src="$theme/out-error-exception.png">},
        out_error_undef_list
            => qq{<img alt="" src="$theme/out-error-undef-list.png">},
        out_error_undef
            => qq{<img alt="" src="$theme/out-error-undef.png">},
        out_hashref => qq{<img alt="" src="$theme/out-hashref.png">},
        out_key_value => qq{<img alt="" src="$theme/out-key-value.png">},
        out_list_or_arrayref
            => qq{<img alt="" src="$theme/out-list-or-arrayref.png.png">},
        out_list => qq{<img alt="" src="$theme/out-list.png">},
        out_object => qq{<img alt="" src="$theme/out-object.png">},
        out_scalar => qq{<img alt="" src="$theme/out-scalar.png">},
        out_subref => qq{<img alt="" src="$theme/out-subref.png">},
    };
}

q|
Creativity is the feeling you get when you realize
your project is due tomorrow
|;

__END__

=encoding utf8

=head1 NAME

Dist::Zilla::Plugin::Pod::Spiffy - make your documentation look spiffy as HTML

=for test_synopsis BEGIN { die "SKIP: Not needed\n"; }

=for Pod::Coverage munge_file

=for stopwords octocat subref subrefs themeing unvolunteer

=head1 SYNOPSIS

In your POD:

    =head2 C<my_super_function>

    =for pod_spiffy in no args | out error undef or list|out hashref

    This function takes two arguments, one of them is mandatory. On
    error it returns either undef or an empty list, depending on the
    context. On success, it returns a hashref.

    ...

    =head1 REPOSITORY

    =for pod_spiffy github Fork this module on https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy

    ...

    =head1 AUTHORS

    =for pod_spiffy authors ZOFFIX JOE SHMOE

    =head1 CONTRIBUTORS

    =for pod_spiffy authors SOME CONTRIBUTOR


In your C<dist.ini>:

    [Pod::Spiffy]

=head1 DESCRIPTION

This L<Dist::Zilla> plugin lets you make your documentation look
spiffy as HTML, by adding meaningful icons. If you're viewing this document
as HTML, you can see available icons below.

The main idea behind this module isn't so much the looks, however, but
the provision of visual hints and clues about various sections of your
documentation, and more importantly the arguments and return values
of the methods/functions.

=head1 HISTORY

I was impressed by L<ETHER|http://metacpan.org/author/ETHER>'s work on
L<Acme::CPANAuthors::Nonhuman> (the including author avatars in the docs
part) and appreciated the added value HTML content can bring to
the POD in my L<Acme::Dump::And::Dumper>.

While working on the implementation of the horribly inconsistent
L<WWW::Goodreads|https://github.com/zoffixznet/WWW-Goodreads>,
I wanted my users to not have to remember the
type of return values for 74+ methods. That's when I thought up the idea
of including icons to give hints of the return types.

=head1 THEME

The current theme is hardcoded to use
C<http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/> However,
since most icons are size-unbound, themeing should be extremely
easy in the future, and configuration option will be provided very soon.

=head1 NOTE ON SCALARS

I realize that hashrefs, subrefs, arrayrefs, and the ilk are all scalars,
but this documentation and the icons by scalars mean the
plain, non-reference types; i.e. strings and numbers (C<42>, C<"foo">, etc.)

=head1 IN YOUR POD

To spiffy-up your POD, use the C<=for> POD command, followed by
C<pod_spiffy>, followed by codes (see L<SYNOPSIS> for examples).
For icons, you can specify multiple icon codes separated with a
pipe character (C<|>). For example:

    =for pod_spiffy in no args

    =for pod_spiffy in no args | out error undef list

You can have any amount of whitespace between individual
words of the codes (but
you must have at least some whitespace). Whitespace around the
C<|> separator is irrelevant.

The following codes are currently available:

=head2 INPUT ARGUMENTS ICONS

These icons provide hints on what your sub/method takes as an argument.

=head3 C<in no args>

    =for pod_spiffy in no args

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-no-args.png">

Use this icon to indicate your sub/method does not take any arguments.

=head3 C<in scalar>

    =for pod_spiffy in scalar

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-scalar.png">

Use this icon to indicate your sub/method takes a plain
scalar as an argument.

=head3 C<in scalar scalar optional>

    =for pod_spiffy in scalar scalar optional

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-scalar-scalar-optional.png">

Use this icon to indicate your sub/method takes as arguments one
mandatory and one optional arguments, both of which are plain
scalars.

=head3 C<in arrayref>

    =for pod_spiffy in arrayref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-arrayref.png">

Use this icon to indicate your sub/method takes an arrayref as an argument.

=head3 C<in hashref>

    =for pod_spiffy in hashref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-hashref.png">

Use this icon to indicate your sub/method takes an hashref as an argument.

=head3 C<in key value>

    =for pod_spiffy in key value

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-key-value.png">

Use this icon to indicate your sub/method takes a list of
key/value pairs as an argument
(e.g. C<< ->method( foo => 'bar', ber => 'biz' ); >>.

=head3 C<in list>

    =for pod_spiffy in list

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-list.png">

Use this icon to indicate your sub/method takes a list
of scalars as an argument (e.g. C<qw/foo bar baz ber/>)

=head3 C<in object>

    =for pod_spiffy in object

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-object.png">

Use this icon to indicate your sub/method takes an object as an argument.

=head3 C<in scalar optional>

    =for pod_spiffy in scalar optional

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-scalar-optional.png">

Use this icon to indicate your sub/method takes a
single B<optional> argument that is a scalar.

=head3 C<in scalar or arrayref>

    =for pod_spiffy in scalar or arrayref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-scalar-or-arrayref.png">

Use this icon to indicate your sub/method takes either
a plain scalar or an arrayref as an argument.

=head3 C<in subref>

    =for pod_spiffy in subref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/in-subref.png">

Use this icon to indicate your sub/method takes a subref as an argument.

=head2 OUTPUT ON ERROR ICONS

These icons are to indicate what your sub/method returns if an
error occurs during its execution.

=head3 C<out error exception>

    =for pod_spiffy out error exception

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-error-exception.png">

Use this icon to indicate your sub/method on error throws an exception.

=head3 C<out error undef or list>

    =for pod_spiffy out error undef or list

=for html <span>Icon: </span>



Use this icon to indicate your sub/method on error returns
either C<undef> or an empty list, depending on the context.

=head3 C<out error undef>

    =for pod_spiffy out error undef

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-error-undef.png">

Use this icon to indicate your sub/method on error returns
C<undef> (regardless of the context).

=head2 OUTPUT ICONS

These icons are to indicate what your sub/method returns after
a successful     execution.

=head3 C<out scalar>

    =for pod_spiffy out scalar

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-scalar.png">

Use this icon to indicate your sub/method returns a plain scalar.

=head3 C<out arrayref>

    =for pod_spiffy out arrayref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-arrayref.png">

Use this icon to indicate your sub/method returns an arrayref.

=head3 C<out hashref>

    =for pod_spiffy out hashref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-hashref.png">

Use this icon to indicate your sub/method returns a hashref.

=head3 C<out key value>

    =for pod_spiffy out key value

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-key-value.png">

Use this icon to indicate your sub/method returns a list of
key value pairs (i.e., return is suitable to assign to a hash).

=head3 C<out list>

    =for pod_spiffy out list

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-list.png">

Use this icon to indicate your sub/method returns a list of
things (i.e., return is suitable to assign to an array).

=head3 C<out list or arrayref>

    =for pod_spiffy out list or arrayref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-list-or-arrayref.png.png">

Use this icon to indicate your sub/method returns either a list of
things or an arrayref, depending on the context.

=head3 C<out subref>

    =for pod_spiffy out subref

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-subref.png">

Use this icon to indicate your sub/method returns a subref.

=head3 C<out object>

    =for pod_spiffy out object

=for html <span>Icon: </span>

=for html  <img alt="" src="http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/out-object.png">

Use this icon to indicate your sub/method returns a object.

=head2 OTHER FEATURES

=head3 Github Repo

B<EXPERIMENTAL!> This feature is still experimental and the API
will likely change. Currently, it adds a github octocat icon to the
left of the github repo text; currently suggested usage is as follows,
although, this is very likely to change in the future. Use
C<github> code to display this; followed by the HTML code you want to
be displayed to the right of the octocat icon.

    =for pod_spiffy github Fork this module on GitHub:
    <a href="https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy">https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy</a>

    =for :text Fork this module on GitHub:
    L<https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy>

=head3 CPAN Authors

B<EXPERIMENTAL!> This feature is still experimental and the appearance
of the output will likely change.
Currently, this feature adds an avatar of the author, and their PAUSE
ID. To use this feature use C<authors> code, followed by a
whitespace separated list of PAUSE author IDs, for example:

    =for pod_spiffy author ZOFFIX ETHER

=head1 REPOSITORY

=for html  <p style="background: url(http://zoffix.com/CPAN/Dist-Zilla-Plugin-Pod-Spiffy/icons/github.png) no-repeat left; padding-left: 120px; min-height: 61px; padding-top: 30px;">Fork this module on GitHub: <a href="https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy">https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy</a></p>

=for :text Fork this module on GitHub:
L<https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy>

=head1 BUGS

To report bugs or request features, please use
L<https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy/issues>

If you can't access GitHub, you can email your request
to C<bug-Dist-Zilla-Plugin-Pod-Spiffy at rt.cpan.org>

=head1 AUTHOR

(Ether is an unvolunteer test subject for this experiment :) )

=for html   <a href="http://metacpan.org/author/ZOFFIX" style="float: left; text-align: center;padding-right: 5px;"><img src="http://www.gravatar.com/avatar/328e658ab6b08dfb5c106266a4a5d065?d=http%3A%2F%2Fwww.gravatar.com%2Favatar%2F627d83ef9879f31bdabf448e666a32d5" alt="ZOFFIX" style="display: block;padding-bottom: 5px;">ZOFFIX</a> <a href="http://metacpan.org/author/ETHER" style="float: left; text-align: center;padding-right: 5px;"><img src="http://www.gravatar.com/avatar/bdc5cd06679e732e262f6c1b450a0237?d=http%3A%2F%2Fwww.gravatar.com%2Favatar%2Fbdc5cd06679e732e262f6c1b450a0237" alt="ETHER" style="display: block;padding-bottom: 5px;">ETHER</a><br style="clear: both;">

=for text Zoffix Znet <zoffix at cpan.org>

=head1 LICENSE

You can use and distribute this module under the same terms as Perl itself.
See the C<LICENSE> file included in this distribution for complete
details.

=cut