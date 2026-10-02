#include <QAbstractItemModelTester>
#include <QSignalSpy>
#include <QTest>

#include "CollectionModel.h"

class CollectionModelTest final : public QObject
{
    Q_OBJECT

private slots:
    void showsAllEntriesInitially();
    void filterShowsOnlyMatchingCategory();
    void filterBackToAllRestoresEveryEntry();
    void unknownCategoryIsIgnored();
    void shuffleKeepsTheSameEntries();
    void shuffleUsesMoveSignals();
};

void CollectionModelTest::showsAllEntriesInitially()
{
    CollectionModel model;
    QAbstractItemModelTester tester(&model, QAbstractItemModelTester::FailureReportingMode::QtTest);
    QCOMPARE(model.rowCount(), 12);
    QCOMPARE(model.category(), CollectionModel::kAllCategories);
}

void CollectionModelTest::filterShowsOnlyMatchingCategory()
{
    CollectionModel model;
    QAbstractItemModelTester tester(&model, QAbstractItemModelTester::FailureReportingMode::QtTest);
    QSignalSpy countSpy(&model, &CollectionModel::countChanged);

    model.setCategory(QStringLiteral("Media"));
    QCOMPARE(model.rowCount(), 4);
    QCOMPARE(countSpy.count(), 1);
    for (int row = 0; row < model.rowCount(); ++row) {
        QCOMPARE(model.data(model.index(row), CollectionModel::CategoryRole).toString(),
                 QStringLiteral("Media"));
    }
}

void CollectionModelTest::filterBackToAllRestoresEveryEntry()
{
    CollectionModel model;
    QAbstractItemModelTester tester(&model, QAbstractItemModelTester::FailureReportingMode::QtTest);
    const QStringList original = model.visibleTitles();

    model.setCategory(QStringLiteral("Projects"));
    model.setCategory(QStringLiteral("System"));
    model.setCategory(CollectionModel::kAllCategories);
    QCOMPARE(model.visibleTitles(), original);
}

void CollectionModelTest::unknownCategoryIsIgnored()
{
    CollectionModel model;
    model.setCategory(QStringLiteral("Nope"));
    QCOMPARE(model.category(), CollectionModel::kAllCategories);
    QCOMPARE(model.rowCount(), 12);
}

void CollectionModelTest::shuffleKeepsTheSameEntries()
{
    CollectionModel model;
    QAbstractItemModelTester tester(&model, QAbstractItemModelTester::FailureReportingMode::QtTest);
    model.setCategory(QStringLiteral("Projects"));
    QStringList before = model.visibleTitles();

    model.shuffle();
    QStringList after = model.visibleTitles();
    before.sort();
    after.sort();
    QCOMPARE(after, before);
}

void CollectionModelTest::shuffleUsesMoveSignals()
{
    CollectionModel model;
    QSignalSpy resetSpy(&model, &QAbstractItemModel::modelReset);
    QSignalSpy layoutSpy(&model, &QAbstractItemModel::layoutChanged);
    QSignalSpy removeSpy(&model, &QAbstractItemModel::rowsRemoved);

    for (int i = 0; i < 5; ++i) {
        model.shuffle();
    }
    QCOMPARE(resetSpy.count(), 0);
    QCOMPARE(layoutSpy.count(), 0);
    QCOMPARE(removeSpy.count(), 0);
    QCOMPARE(model.rowCount(), 12);
}

QTEST_GUILESS_MAIN(CollectionModelTest)
#include "tst_collectionmodel.moc"
