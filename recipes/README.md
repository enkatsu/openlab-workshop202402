# 制作時のレシピ

- [Sequencer8x1](Sequencer8x1): 8ステップ1パートのシーケンサ
- [Sequencer4x2](Sequencer4x2): 4ステップ2パートのシーケンサ
- [Jaikenzan](Jaikenzan): じゃいけんざん
- [EuclidRhythmSender](EuclidRhythmSender): ユークリッドのリズム

## シーケンサーのフローチャート

```mermaid
flowchart
    classDef ta-left text-center: left;

    subgraph setup["setup()"]
        initCs[現在のステップを0にする]
        initStep[すべてのステップを非アクティブにする]
    end
    subgraph draw["draw()"]
        loopStart[drawループの先頭]
        subgraph ステップ制御処理
            incStep[ステップを一つ進める]
            ifCsOver{もし現在のステップが\n範囲外なら}:::ta-center
            resetCs[ステップを0にする]
        end
        subgraph OSCの送信処理
            ifStepTrue{もし現在のステップが\nアクティブなら}:::ta-center
            sendOsc[OSCを送信]
        end
    end

    initCs --> initStep
    initStep --> loopStart

    loopStart --> incStep
    incStep --> ifCsOver
    ifCsOver -->|true| resetCs --> ifStepTrue
    ifCsOver -->|false| ifStepTrue
    ifStepTrue --> |true| sendOsc --> incStep
    ifStepTrue --> |false| incStep
```
