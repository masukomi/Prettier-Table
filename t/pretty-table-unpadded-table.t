use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 2;

my $table = Prettier::Table.new: :!header, padding-width => 0;
given $table {
    .add-row(['abc']);
    .add-row(['def']);
    .add-row(['g..']);
}

subtest 'unbordered table', {
    $table.border(False);
    my $result = $table.get-string;
    my $expected = q:to/END/;
    abc
    def
    g..
    END

    ok $result.trim eq $expected.trim, 'Both result and expected tables are the same.';
}

subtest 'bordered table', {
    $table.border(True);
    my $result = $table.get-string;
    my $expected = q:to/END/;
    ┌───┐
    │abc│
    │def│
    │g..│
    └───┘
    END

    ok $result.trim eq $expected.trim, 'Both result and expected tables are the same.';
}
