use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 1;

subtest 'ASCII line break', {
    my $table = Prettier::Table.new(field-names => ['Field 1', 'Field 2']);
    $table.add-row(['value 1', "value2\nsecond line"]);
    $table.add-row(['value 3', 'value4']);
    my $result = $table.get-string(hrules => ALL);
    my $expected = q:to/END/;
    ┌─────────┬─────────────┐
    │ Field 1 │   Field 2   │
    ├─────────┼─────────────┤
    │ value 1 │    value2   │
    │         │ second line │
    ├─────────┼─────────────┤
    │ value 3 │    value4   │
    └─────────┴─────────────┘
    END

    ok $result.trim eq $expected.trim, 'same tables with a single newline.';

    $table = Prettier::Table.new(field-names => ['Field 1', 'Field 2']);
    $table.add-row(['value 1', "value2\nsecond line"]);
    $table.add-row(["value 3\n\nother line", "value4\n\n\nvalue5"]);
    $result = $table.get-string(hrules => ALL);
    $expected = q:to/END/;
    ┌────────────┬─────────────┐
    │  Field 1   │   Field 2   │
    ├────────────┼─────────────┤
    │  value 1   │    value2   │
    │            │ second line │
    ├────────────┼─────────────┤
    │  value 3   │    value4   │
    │            │             │
    │ other line │             │
    │            │    value5   │
    └────────────┴─────────────┘
    END

    ok $result.trim eq $expected.trim, 'same tables with multiple newlines and hrules equal to ALL.';

    $table = Prettier::Table.new(field-names => ['Field 1', 'Field 2']);
    $table.add-row(['value 1', "value2\nsecond line"]);
    $table.add-row(["value 3\n\nother line", "value4\n\n\nvalue5"]);
    $result = $table.get-string();
    $expected = q:to/END/;
    ┌────────────┬─────────────┐
    │  Field 1   │   Field 2   │
    ├────────────┼─────────────┤
    │  value 1   │    value2   │
    │            │ second line │
    │  value 3   │    value4   │
    │            │             │
    │ other line │             │
    │            │    value5   │
    └────────────┴─────────────┘
    END

    ok $result.trim eq $expected.trim, 'same tables with multiple newlines.';
}
