# 制作時のレシピ

- [Sequencer1x8](Sequencer1x8): 1トラック8ステップのシーケンサー
- [Sequencer2x4](Sequencer2x4): 2トラック4ステップのシーケンサー
- [Jaikenzan](Jaikenzan): じゃいけんざん
- [EuclidRhythmSender](EuclidRhythmSender): ユークリッドのリズム

## シーケンサーのフローチャート

```mermaid
flowchart
    classDef ta-left text-center: left;

    subgraph setup["setup()"]
        initCs["現在のステップを0にする
            int currentStep = 0;"]
        initStep["すべてのステップを非アクティブにする
            for (int i = 0; i < steps.length; i++) { steps[i] = false; }"]
    end
    subgraph draw["draw()"]
        loopStart[drawループの先頭]
        drawGrid["グリッドの描画"]
        subgraph ステップを進める処理
            incStep["ステップを一つ進める
                currentStep++;"]
            ifCsOver{"もし現在のステップが範囲外なら
                if (currentStep >= steps.length)"}:::ta-center
            resetCs["ステップを0にする
                currentStep = 0;"]
        end
        subgraph OSCの送信処理
            ifStepTrue{"もし現在のステップがアクティブなら
                if (steps[currentStep])"}:::ta-center
            sendOsc["OSCを送信
                OscMessage message = new OscMessage(/bang);
                oscP5.send(message, addresses[currentStep]);
                println(addresses[currentStep], message);"]
        end
    end

    initCs --> initStep
    initStep --> loopStart

    loopStart --> drawGrid --> incStep
    incStep --> ifCsOver
    ifCsOver -->|true| resetCs --> ifStepTrue
    ifCsOver -->|false| ifStepTrue
    ifStepTrue --> |true| sendOsc --> loopStart
    ifStepTrue --> |false| loopStart
```
