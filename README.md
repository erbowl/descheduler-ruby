# descheduler-ruby
delete long-running application on k8s

想定される使用例は、長期間稼働させるとメモリが解放されないアプリケーションを定期的に再起動してあげる、などです。

やっていることは単純です。

- 定期的にPodの一覧を取得
- 指定された期間以上稼働しているpodがあればdelete
- 一気に消すと不安定になると思われるのでintervalを開ける

`crd.yml`で定義されたdeschedulerというカスタムリソースを使用して設定を受け取ります。

---

An Example use case is to periodically reboot an application that will not free up memory after a long period of time.

What we're doing is simple.

- Get a list of Pods on a regular basis.
- Delete any PODs that have been running for more than the specified period of time.
- It may become unstable if you erase it all at once, so open the interval.

It receives the configuration using the custom resource descheduler defined in `crd.yml`.

Translated with www.DeepL.com/Translator (free version)
