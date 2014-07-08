package Perl::Lint::Evaluator::ValuesAndExpressions::RequireNumberSeparators;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $min_value = $args->{require_number_separators}->{min_value} || 100_000;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == INT || $token_type == DOUBLE) {
            (my $num = $token->{data}) =~ s/\A[+-]//;

            my ($decimal_part, $fractional_part) = split /\./, $num;
            my @decimals    = split /_/, $decimal_part;
            my @fractionals = split(/_/, $fractional_part || 0);

            if (join('', @decimals) . '.' . join('', @fractionals) < $min_value) {
                next;
            }

            for my $part (@decimals, @fractionals) {
                if ($part >= 1000) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

