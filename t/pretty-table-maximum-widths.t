use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 2;

subtest 'max table width is the law', {
    my $max-width = 127;
    my $table = Prettier::Table.new: max-table-width => $max-width;
    $table.field-names(['tag', 'versions']);

    my @versions = (
        'python/django-appconf:1.0.1',
        'python/django-braces:1.8.1',
        'python/django-compressor:2.0',
        'python/django-debug-toolbar:1.4',
        'python/django-extensions:1.6.1',
    );

    $table.add-row(['allmychanges.com', @versions.join(', ')]);
    my $result = $table.get-string(:hrules(ALL));
    my @lines = $result.split("\n", :skip-empty);
    for @lines -> $line {
        ok $line.chars == $max-width, 'Max table width dictates each row\'s width.';
    }
}

subtest 'max table width is the law when min column width is set for some columns', {
    my $max-width = 40;
    my $table = Prettier::Table.new: max-table-width => $max-width;
    $table.field-names(['tag', 'versions']);
    my @versions = (
        'python/django-appconf:1.0.1',
        'python/django-braces:1.8.1',
        'python/django-compressor:2.0',
        'python/django-debug-toolbar:1.4',
        'python/django-extensions:1.6.1',
    );
    $table.add-row(['allmychanges.com', @versions.join(', ')]);

    # set minimum width for the first column in order to prevent wrapping its content.
    $table.min-width( %(tag => 'allmychanges.com'.chars) );

    my $result = $table.get-string(:hrules(ALL));
    my @lines = $result.split("\n", :skip-empty);

    for @lines -> $line {
        ok $line.chars == $max-width, 'Max table width dictates each row\'s width.';
    }
}
