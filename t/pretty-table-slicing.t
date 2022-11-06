use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

warn("DISABLED SLICE TEST \nsee https://github.com/rakudo/rakudo/issues/5079");
done-testing;

# plan 3;

# my Prettier::Table $table .= new:
#     field-names => ["City name", "Area", "Population", "Annual Rainfall"],
# ;

# given $table {
#     .add-row(["Adelaide", 1295, 1158259, 600.5]);
#     .add-row(["Brisbane", 5905, 1857594, 1146.4]);
#     .add-row(["Darwin", 112, 120900, 1714.7]);
#     .add-row(["Hobart", 1357, 205556, 619.5]);
#     .add-row(["Sydney", 2058, 4336374, 1214.8]);
#     .add-row(["Melbourne", 1566, 3806092, 646.9]);
#     .add-row(["Perth", 5386, 1554769, 869.4]);
# }

# subtest 'slicing all', {
#     my $x = $table[0 ..^ $table.elems];
#     ok $table.Str.trim eq $x.Str.trim, 'Original and its full slice are the same.';
# }

# subtest 'slicing first two rows', {
#     my Prettier::Table $x = $table.[0 ..^ 2];
#     given $x.get-string {
#         ok  .split("\n").elems == 6, 'Sliced table has right number of newlines.';
#         ok  .contains('Adelaide'), 'Sliced table contains city in the range.';
#         ok  .contains('Brisbane'), 'Sliced table contains city in the range.';
#         nok .contains('Melbourne'), 'Sliced table doesn\'t contain city outside the range.';
#         nok .contains('Perth'), 'Sliced table doesn\'t contain city outside the range.';
#     }
# }

# subtest 'slicing last two rows', {
#     my Prettier::Table $x = $table[$table.elems-2 .. $table.elems-1];
#     given $x.get-string {
#         ok  .split("\n").elems == 6, 'Sliced table has right number of newlines.';
#         nok .contains('Adelaide'), 'Sliced table doesn\'t contain city outside the range.';
#         nok .contains('Brisbane'), 'Sliced table doesn\'t contain city outside the range.';
#         ok  .contains('Melbourne'), 'Sliced table contains city in the range.';
#         ok  .contains('Perth'), 'Sliced table contains city in the range.';
#     }
# }
